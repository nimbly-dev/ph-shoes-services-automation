output "name" {
  value       = aws_resourcegroups_group.this.name
  description = "Resource group name"
}

output "arn" {
  value       = aws_resourcegroups_group.this.arn
  description = "Resource group ARN"
}
