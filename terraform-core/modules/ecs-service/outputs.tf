output "service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "security_group_id" {
  value       = aws_security_group.service.id
  description = "Service security group"
}

output "log_group_name" {
  value       = local.log_group_name
  description = "CloudWatch log group name"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "Task definition ARN"
}

output "execution_role_arn" {
  value       = local.execution_role_arn
  description = "IAM execution role ARN used by the service"
}

output "task_role_arn" {
  value       = local.task_role_arn
  description = "IAM task role ARN used by the service"
}
