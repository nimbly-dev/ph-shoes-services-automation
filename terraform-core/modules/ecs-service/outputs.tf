output "service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "security_group_id" {
  value       = aws_security_group.service.id
  description = "Service security group"
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.service.name
  description = "CloudWatch log group name"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "Task definition ARN"
}
