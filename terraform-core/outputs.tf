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
