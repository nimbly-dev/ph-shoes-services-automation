locals {
  common_tags = merge({
    Project   = "phshoes"
    ManagedBy = "terraform"
    Env       = var.env
  }, var.tags)

  table_arn_pattern = "arn:aws:dynamodb:${var.aws_region}:*:table/*"
  index_arn_pattern = "arn:aws:dynamodb:${var.aws_region}:*:table/*/index/*"
}

# IAM user
resource "aws_iam_user" "svc" {
  name = "${var.name_prefix}-accounts-service-user"
  tags = local.common_tags
  lifecycle { create_before_destroy = true }
}

# --- DynamoDB policy: introspect + create/update + data ops ---
data "aws_iam_policy_document" "ddb" {
  # Introspection (safe on "*")
  statement {
    sid     = "Introspect"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeLimits"
    ]
    resources = ["*"]
  }

  # Allow creating new tables (MUST be "*" per AWS)
  statement {
    sid       = "CreateTables"
    actions   = ["dynamodb:CreateTable"]
    resources = ["*"]
  }

  # Allow updating existing tables/GSIs and tagging
  statement {
    sid     = "UpdateTablesAndTags"
    actions = [
      "dynamodb:UpdateTable",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:TagResource",
      "dynamodb:UntagResource"
    ]
    resources = [
      local.table_arn_pattern,
      local.index_arn_pattern
    ]
  }

  # Data operations on all tables/GSIs in region
  statement {
    sid     = "DataOpsAllTables"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:ConditionCheckItem"
    ]
    resources = [
      local.table_arn_pattern,
      local.index_arn_pattern
    ]
  }
}


resource "aws_iam_policy" "ddb" {
  name        = "${var.name_prefix}-accounts-ddb"
  description = "Create/Update and DataOps on all DynamoDB tables/GSIs in ${var.aws_region}"
  policy      = data.aws_iam_policy_document.ddb.json
  tags        = local.common_tags
}

resource "aws_iam_user_policy_attachment" "svc_ddb" {
  user       = aws_iam_user.svc.name
  policy_arn = aws_iam_policy.ddb.arn
}

# --- SES send: region + From address ---
data "aws_iam_policy_document" "ses" {
  statement {
    sid       = "SendEmail"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses" {
  name        = "${var.name_prefix}-accounts-ses"
  description = "Allow sending email from ${var.ses_from_address} in ${var.aws_region}"
  policy      = data.aws_iam_policy_document.ses.json
  tags        = local.common_tags
}

resource "aws_iam_user_policy_attachment" "svc_ses" {
  user       = aws_iam_user.svc.name
  policy_arn = aws_iam_policy.ses.arn
}

# Optional access key for dev
resource "aws_iam_access_key" "svc" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.svc.name
}
