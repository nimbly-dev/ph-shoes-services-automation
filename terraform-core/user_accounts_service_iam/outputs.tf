output "user_name" {
  value       = aws_iam_user.svc.name
  description = "Service IAM user name"
}

output "user_arn" {
  value       = aws_iam_user.svc.arn
  description = "Service IAM user ARN"
}

output "ddb_policy_arn" {
  value       = aws_iam_policy.ddb.arn
  description = "Attached DynamoDB policy ARN"
}

output "ses_policy_arn" {
  value       = aws_iam_policy.ses.arn
  description = "Attached SES policy ARN"
}

output "access_key_id" {
  value       = try(aws_iam_access_key.svc[0].id, null)
  description = "Access key ID (if created)"
  sensitive   = true
}

output "secret_access_key" {
  value       = try(aws_iam_access_key.svc[0].secret, null)
  description = "Secret access key (if created). Store it in a secret manager immediately."
  sensitive   = true
}
