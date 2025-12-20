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

# DNS-related outputs moved to terraform-dns module

output "backend_execution_role_arn" {
  description = "Shared execution role ARN for backend services"
  value       = module.backend_iam_roles.execution_role_arn
}

output "backend_task_role_arn" {
  description = "Shared task role ARN for backend services"
  value       = module.backend_iam_roles.task_role_arn
}

output "frontend_execution_role_arn" {
  description = "Execution role ARN for frontend service"
  value       = module.frontend_iam_roles.execution_role_arn
}

output "frontend_task_role_arn" {
  description = "Task role ARN for frontend service"
  value       = module.frontend_iam_roles.task_role_arn
}

# CloudWatch Monitoring Outputs
output "cloudwatch_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = var.enable_cloudwatch_monitoring ? module.cloudwatch_monitoring[0].sns_topic_arn : null
}

output "cloudwatch_sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarms"
  value       = var.enable_cloudwatch_monitoring ? module.cloudwatch_monitoring[0].sns_topic_name : null
}

output "cloudwatch_task_count_alarms" {
  description = "Names of the task count zero alarms"
  value       = var.enable_cloudwatch_monitoring ? module.cloudwatch_monitoring[0].task_count_alarm_names : []
}

output "cloudwatch_cpu_alarms" {
  description = "Names of the CPU utilization alarms"
  value       = var.enable_cloudwatch_monitoring ? module.cloudwatch_monitoring[0].cpu_alarm_names : []
}

output "cloudwatch_memory_alarms" {
  description = "Names of the memory utilization alarms"
  value       = var.enable_cloudwatch_monitoring ? module.cloudwatch_monitoring[0].memory_alarm_names : []
}

# CloudWatch Dashboards Outputs (Task 12.2)
output "system_overview_dashboard_url" {
  description = "URL for the System Overview Dashboard"
  value       = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].system_overview_dashboard_url : null
}

output "service_performance_dashboard_url" {
  description = "URL for the Service Performance Dashboard"
  value       = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].service_performance_dashboard_url : null
}

output "infrastructure_dashboard_url" {
  description = "URL for the Infrastructure Dashboard"
  value       = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].infrastructure_dashboard_url : null
}

output "dashboard_names" {
  description = "List of created CloudWatch dashboard names"
  value       = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].dashboard_names : []
}

output "cloudwatch_insights_queries" {
  description = "List of CloudWatch Insights query definition names"
  value       = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].query_definition_names : []
}

output "composite_alarms" {
  description = "List of composite alarm names for intelligent alerting"
  value       = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].composite_alarm_names : []
}


# Enhanced CloudWatch Dashboard Outputs
output "enhanced_dashboard_url" {
  description = "URL for the Enhanced Observability Dashboard"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].enhanced_dashboard_url : null
}

output "enhanced_dashboard_name" {
  description = "Name of the enhanced observability dashboard"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].enhanced_dashboard_name : null
}

output "enhanced_query_definitions" {
  description = "List of enhanced CloudWatch Insights query definition names"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].query_definition_names : []
}

output "enhanced_log_groups" {
  description = "List of managed log group names with optimized retention"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].log_group_names : []
}

output "enhanced_free_tier_usage" {
  description = "Enhanced dashboard free tier usage summary"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].free_tier_usage_summary : null
}

output "enhanced_dashboard_panels" {
  description = "Summary of enhanced dashboard panels and widget counts"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].dashboard_panels_summary : null
}

output "enhanced_insights_query_urls" {
  description = "Direct URLs to enhanced CloudWatch Insights queries"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].cloudwatch_insights_query_urls : null
}

output "enhanced_free_tier_compliance" {
  description = "Enhanced dashboard free tier compliance status and safety margins"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].free_tier_compliance_status : null
}

output "enhanced_monitoring_alarms" {
  description = "List of enhanced monitoring alarm names for usage tracking"
  value       = var.enable_enhanced_cloudwatch_dashboard ? module.enhanced_cloudwatch_dashboard[0].monitoring_alarm_names : []
}

# Combined Dashboard Summary
output "all_dashboard_summary" {
  description = "Summary of all CloudWatch dashboards (existing + enhanced)"
  value = {
    existing_dashboards   = var.enable_cloudwatch_dashboards ? module.cloudwatch_dashboards[0].dashboard_names : []
    enhanced_dashboard    = var.enable_enhanced_cloudwatch_dashboard ? [module.enhanced_cloudwatch_dashboard[0].enhanced_dashboard_name] : []
    total_dashboard_count = (var.enable_cloudwatch_dashboards ? 3 : 0) + (var.enable_enhanced_cloudwatch_dashboard ? 1 : 0)
    free_tier_usage       = "${(var.enable_cloudwatch_dashboards ? 3 : 0) + (var.enable_enhanced_cloudwatch_dashboard ? 1 : 0)}/10 dashboards"
    free_tier_percentage  = "${((var.enable_cloudwatch_dashboards ? 3 : 0) + (var.enable_enhanced_cloudwatch_dashboard ? 1 : 0)) * 10}% of free tier limit"
  }
}