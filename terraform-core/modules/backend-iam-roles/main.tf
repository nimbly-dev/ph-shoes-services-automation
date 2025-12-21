resource "aws_iam_role" "execution" {
  name = "${var.name_prefix}-backend-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${var.name_prefix}-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "task_secrets" {
  name = "secrets-access"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "task_dynamodb" {
  name = "dynamodb-access"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:DescribeTable",
        "dynamodb:CreateTable",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:UpdateTimeToLive"
      ]
      Resource = [
        "arn:aws:dynamodb:*:*:table/accounts",
        "arn:aws:dynamodb:*:*:table/login_sessions",
        "arn:aws:dynamodb:*:*:table/account_verifications",
        "arn:aws:dynamodb:*:*:table/email_suppressions",
        "arn:aws:dynamodb:*:*:table/alerts",
        "arn:aws:dynamodb:*:*:table/accounts/index/*",
        "arn:aws:dynamodb:*:*:table/login_sessions/index/*",
        "arn:aws:dynamodb:*:*:table/account_verifications/index/*",
        "arn:aws:dynamodb:*:*:table/email_suppressions/index/*",
        "arn:aws:dynamodb:*:*:table/alerts/index/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy" "task_ses" {
  name = "ses-send-access"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail",
        "ses:SendTemplatedEmail"
      ]
      Resource = "*"
    }]
  })
}
