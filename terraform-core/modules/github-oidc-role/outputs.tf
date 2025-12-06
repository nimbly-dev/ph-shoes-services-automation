output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.github.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.github.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN used by the role"
  value       = local.oidc_provider_arn
}
