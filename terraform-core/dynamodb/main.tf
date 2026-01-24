# /dynamodb/main.tf

# Who am I? (for ARNs)
data "aws_caller_identity" "me" {}

# Runtime principal + ARN patterns we’ll constrain with ResourceTag conditions
locals {
  runtime_principal = var.runtime == "ecs" ? "ecs-tasks.amazonaws.com" : (
    var.runtime == "ec2" ? "ec2.amazonaws.com" : "lambda.amazonaws.com"
  )

  table_arn_pattern = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.me.account_id}:table/*"
  index_arn_pattern = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.me.account_id}:table/*/index/*"
}

# Assume role policy for ECS / EC2 / Lambda (selected via var.runtime)
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [local.runtime_principal]
    }
  }
}

resource "aws_iam_role" "service" {
  name               = "${var.service_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

# Tag-guarded DynamoDB management: app can create & operate ONLY on Project/Env-tagged resources
data "aws_iam_policy_document" "dynamodb_manage" {
  # Safe, read-only introspection on *
  statement {
    sid = "Introspect"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeLimits"
    ]
    resources = ["*"]
  }

  # CreateTable only if request includes required tags
  statement {
    sid       = "CreateTablesWithRequiredTags"
    actions   = ["dynamodb:CreateTable"]
    resources = ["*"]

    # Require Project + Env tag values on the request
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_tag]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Env"
      values   = [var.env_tag]
    }
    # Ensure these tag keys are present at creation (Service value can be any)
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = ["Project", "Env", "Service"]
    }
  }

  # Update table props / TTL / tagging on tables & indexes that are tagged for this Project+Env
  statement {
    sid = "UpdateTables"
    actions = [
      "dynamodb:UpdateTable",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:TagResource",
      "dynamodb:UntagResource"
    ]
    resources = [local.table_arn_pattern, local.index_arn_pattern]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_tag]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Env"
      values   = [var.env_tag]
    }
  }

  # Data operations only on Project+Env-tagged tables & their GSIs
  statement {
    sid = "DataOps"
    actions = concat([
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:ConditionCheckItem"
    ], var.extra_data_actions)

    resources = [local.table_arn_pattern, local.index_arn_pattern]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_tag]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Env"
      values   = [var.env_tag]
    }
  }

  # Optional DeleteTable (usually disabled in prod)
  dynamic "statement" {
    for_each = var.allow_table_delete ? [1] : []
    content {
      sid       = "DeleteTables"
      actions   = ["dynamodb:DeleteTable"]
      resources = [local.table_arn_pattern]

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceTag/Project"
        values   = [var.project_tag]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:ResourceTag/Env"
        values   = [var.env_tag]
      }
    }
  }

}

resource "aws_iam_policy" "dynamodb_manage" {
  name   = "${var.service_name}-dynamodb-manage"
  policy = data.aws_iam_policy_document.dynamodb_manage.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_manage" {
  role       = aws_iam_role.service.name
  policy_arn = aws_iam_policy.dynamodb_manage.arn
}

# Instance profile (only for EC2 runtime)
resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.runtime == "ec2" ? 1 : 0
  name  = "${var.service_name}-instance-profile"
  role  = aws_iam_role.service.name
  tags  = var.tags
}
