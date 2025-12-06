locals {
  default_subjects = [
    for repo in var.github_repositories : "repo:${var.github_owner}/${repo}:*"
  ]
  subjects = length(var.github_subjects) > 0 ? var.github_subjects : local.default_subjects
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider && var.existing_oidc_provider_arn == "" ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

locals {
  oidc_provider_arn = var.existing_oidc_provider_arn != "" ? var.existing_oidc_provider_arn : try(aws_iam_openid_connect_provider.github[0].arn, "")
}

resource "aws_iam_role" "github" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.subjects
    }
  }
}

data "aws_iam_policy_document" "ecr_public" {
  statement {
    sid    = "EcrPublicPush"
    effect = "Allow"
    actions = [
      "ecr-public:GetAuthorizationToken",
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:PutImage",
      "ecr-public:InitiateLayerUpload",
      "ecr-public:UploadLayerPart",
      "ecr-public:CompleteLayerUpload",
      "ecr-public:DescribeRepositories",
      "ecr-public:DescribeImages",
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_public" {
  count  = var.attach_ecr_public_policy ? 1 : 0
  role   = aws_iam_role.github.id
  policy = data.aws_iam_policy_document.ecr_public.json
}

resource "aws_iam_role_policy" "additional" {
  count  = var.additional_policy_json == null ? 0 : 1
  role   = aws_iam_role.github.id
  policy = var.additional_policy_json
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.github.name
  policy_arn = each.value
}
