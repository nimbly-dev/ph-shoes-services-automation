output "role_name" { value = aws_iam_role.service.name }
output "role_arn" { value = aws_iam_role.service.arn }
output "policy_arn" { value = aws_iam_policy.dynamodb_manage.arn }

output "ec2_instance_profile_name" {
  value       = try(aws_iam_instance_profile.ec2_profile[0].name, null)
  description = "Only present when runtime = ec2"
}
