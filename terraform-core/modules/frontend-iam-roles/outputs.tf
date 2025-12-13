output "execution_role_arn" {
  description = "ARN of the ECS task execution role for frontend"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role for frontend"
  value       = aws_iam_role.task.arn
}