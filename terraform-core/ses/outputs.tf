output "policy_arn" {
  description = "ARN of the SES send policy"
  value       = aws_iam_policy.ses_send.arn
}

output "attached_to_role" {
  description = "Whether the policy was attached to a role by this module"
  value       = length(var.attach_to_role_name) > 0
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic receiving SES events (if created)"
  value       = try(aws_sns_topic.ses_events[0].arn, null)
}

output "configuration_set_name" {
  description = "Name of the SES configuration set (if created)"
  value       = try(aws_sesv2_configuration_set.this[0].configuration_set_name, null)
}
