output "project_resource_group_name" {
  description = "Name of the AWS Resource Group created for the project"
  value       = module.project_resource_group.name
}

output "project_resource_group_arn" {
  description = "ARN of the AWS Resource Group"
  value       = module.project_resource_group.arn
}

output "app_registry_application_id" {
  description = "ID of the Service Catalog AppRegistry application"
  value       = module.app_registry_application.id
}

output "app_registry_application_arn" {
  description = "ARN of the Service Catalog AppRegistry application"
  value       = module.app_registry_application.arn
}

output "public_ecr_repositories" {
  description = "Map of ECR Public repositories managed by Terraform"
  value       = module.public_ecr_repositories.repositories
}

output "github_oidc_role_name" {
  description = "IAM role name assumed by GitHub Actions"
  value       = module.github_oidc_role.role_name
}

output "github_oidc_role_arn" {
  description = "IAM role ARN used by GitHub Actions"
  value       = module.github_oidc_role.role_arn
}

output "github_oidc_provider_arn" {
  description = "OIDC provider ARN used in the trust policy"
  value       = module.github_oidc_role.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC ID for the ECS workloads"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets used by ECS"
  value       = module.network.public_subnet_ids
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_capacity_provider_name" {
  description = "Capacity provider backing the ECS cluster"
  value       = module.ecs_cluster.capacity_provider_name
}

output "ecs_instance_security_group_id" {
  description = "Security group protecting ECS instances"
  value       = module.ecs_cluster.instance_security_group_id
}

output "common_tags" {
  description = "Standard tags applied to resources"
  value       = local.common_tags
}

output "frontend_alb_dns_name" {
  description = "DNS name of the frontend ALB (when enabled)"
  value       = try(module.frontend_alb[0].alb_dns_name, null)
}

output "frontend_service_name" {
  description = "Name of the frontend ECS service (when enabled)"
  value       = try(module.frontend_service[0].service_name, null)
}
