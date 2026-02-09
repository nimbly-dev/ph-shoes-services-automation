data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ses_send" {
  statement {
    sid       = "SendEmail"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]

    dynamic "condition" {
      for_each = var.restrict_to_region ? [1] : []
      content {
        test     = "StringEquals"
        variable = "aws:RequestedRegion"
        values   = [var.aws_region]
      }
    }
  }
}

resource "aws_iam_policy" "ses_send" {
  name   = "${var.service_name}-ses-send"
  policy = data.aws_iam_policy_document.ses_send.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_ses_send" {
  count      = length(var.attach_to_role_name) > 0 ? 1 : 0
  role       = var.attach_to_role_name
  policy_arn = aws_iam_policy.ses_send.arn
}

locals {
  create_event_resources = var.enable_event_destination && var.configuration_set_name != "" && var.sns_topic_name != "" && var.webhook_endpoint != ""
  configuration_set_arn  = "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:configuration-set/${var.configuration_set_name}"
  account_root_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

resource "aws_sesv2_configuration_set" "this" {
  count = local.create_event_resources ? 1 : 0

  configuration_set_name = var.configuration_set_name
  tags                   = var.tags
}

resource "aws_sns_topic" "ses_events" {
  count = local.create_event_resources ? 1 : 0

  name = var.sns_topic_name
  tags = var.tags
}

data "aws_iam_policy_document" "sns_topic" {
  count = local.create_event_resources ? 1 : 0

  statement {
    sid       = "AllowOwnerAllActions"
    effect    = "Allow"
    # SNS topic policies reject wildcards like "SNS:*" in some accounts/regions.
    # Keep this explicit to avoid "Policy statement action out of service scope!".
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
    ]
    resources = [aws_sns_topic.ses_events[0].arn]

    principals {
      type        = "AWS"
      identifiers = [local.account_root_arn]
    }
  }

  statement {
    sid     = "AllowSESPublishFromConfigSet"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [aws_sns_topic.ses_events[0].arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = [local.configuration_set_arn]
    }
  }
}

resource "aws_sns_topic_policy" "allow_ses" {
  count = local.create_event_resources ? 1 : 0

  arn    = aws_sns_topic.ses_events[0].arn
  policy = data.aws_iam_policy_document.sns_topic[0].json
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  count = local.create_event_resources ? 1 : 0

  configuration_set_name = aws_sesv2_configuration_set.this[0].configuration_set_name
  event_destination_name = var.event_destination_name

  event_destination {
    enabled              = true
    matching_event_types = var.matching_event_types

    sns_destination {
      topic_arn = aws_sns_topic.ses_events[0].arn
    }
  }

  depends_on = [aws_sns_topic_policy.allow_ses]
}

resource "aws_sns_topic_subscription" "webhook" {
  count = local.create_event_resources ? 1 : 0

  topic_arn = aws_sns_topic.ses_events[0].arn
  protocol  = "https"
  endpoint  = var.webhook_endpoint

  # Our webhook auto-confirms SNS subscriptions; don't block `apply` waiting on manual confirmation.
  endpoint_auto_confirms = true
  confirmation_timeout_in_minutes = 10
}
