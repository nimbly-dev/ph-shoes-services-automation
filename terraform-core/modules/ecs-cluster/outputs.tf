output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "cluster_arn" {
  value       = aws_ecs_cluster.this.arn
  description = "ECS cluster ARN"
}

output "capacity_provider_name" {
  value       = aws_ecs_capacity_provider.this.name
  description = "Capacity provider name"
}

output "instance_security_group_id" {
  value       = aws_security_group.ecs_instances.id
  description = "Security group ID for ECS instances"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.ecs.name
  description = "ECS Auto Scaling Group name"
}

output "launch_template_id" {
  value       = aws_launch_template.ecs.id
  description = "Launch template ID"
}
