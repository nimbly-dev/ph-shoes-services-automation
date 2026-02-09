# Outputs for Deployment Dashboard Module

output "dashboard_name" {
  description = "Name of the Deployment Dashboard"
  value       = aws_cloudwatch_dashboard.deployment_dashboard.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the Deployment Dashboard"
  value       = aws_cloudwatch_dashboard.deployment_dashboard.dashboard_arn
}

output "dashboard_url" {
  description = "URL to access the Deployment Dashboard in AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.deployment_dashboard.dashboard_name}"
}

output "query_definition_names" {
  description = "List of CloudWatch Insights query definition names for deployment monitoring (managed by simplified_cloudwatch_queries module)"
  value = [
    # Query definitions are managed by simplified_cloudwatch_queries module to avoid duplication
    # "ph-shoes-services-ecs-ecs-deployment-events",
    # "ph-shoes-services-ecs-container-startup-logs", 
    aws_cloudwatch_query_definition.deployment_troubleshooting.name
  ]
}

output "query_definition_ids" {
  description = "List of CloudWatch Insights query definition IDs for deployment monitoring (managed by simplified_cloudwatch_queries module)"
  value = [
    # Query definitions are managed by simplified_cloudwatch_queries module to avoid duplication
    # Reference simplified_cloudwatch_queries module outputs for these IDs
    aws_cloudwatch_query_definition.deployment_troubleshooting.query_definition_id
  ]
}

output "deployment_log_groups" {
  description = "Map of service names to their CloudWatch log group names for deployment monitoring"
  value = {
    for service_key, service in local.services : service_key => service.log_group
  }
}

output "ecs_cluster_log_group" {
  description = "ECS cluster performance log group for deployment monitoring"
  value       = "/aws/ecs/containerinsights/${var.cluster_name}/performance"
}

output "deployment_config" {
  description = "Deployment monitoring configuration settings"
  value = {
    deployment_timeout_minutes = local.deployment_config.deployment_timeout_minutes
    startup_timeout_minutes    = local.deployment_config.startup_timeout_minutes
    memory_startup_threshold   = local.deployment_config.memory_startup_threshold
  }
}

output "dashboard_widget_count" {
  description = "Number of widgets in the Deployment Dashboard"
  value       = 6
}

output "free_tier_usage_estimate" {
  description = "Estimated free tier usage for this deployment dashboard (queries managed by simplified_cloudwatch_queries module)"
  value = {
    dashboards = "1/10 (10%)"
    metrics    = "~3/50 (6%)"
    api_calls  = "~120/month (1.2%)"
    queries    = "1 saved query (others managed by simplified_cloudwatch_queries module)"
  }
}

output "deployment_quick_links" {
  description = "Quick access URLs for deployment monitoring"
  value = {
    cluster_overview    = "https://${data.aws_region.current.name}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name}"
    task_definitions    = "https://${data.aws_region.current.name}.console.aws.amazon.com/ecs/v2/task-definitions"
    service_events      = "https://${data.aws_region.current.name}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name}/services"
    cloudwatch_insights = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logs-insights:"
  }
}

output "portfolio_demo_readiness_checklist" {
  description = "Portfolio demo readiness validation checklist"
  value = {
    deployment_checks = [
      "All 5 services deployed",
      "No failed deployments in last hour",
      "All containers started successfully",
      "Memory usage stable during startup"
    ]
    service_health_checks = [
      "Frontend SPA accessible (Port 80)",
      "User Accounts API responding (Port 8082)",
      "Catalog API responding (Port 8083)",
      "Alerts API responding (Port 8084)",
      "Text Search API responding (Port 8085)"
    ]
    validation_steps = [
      "Check ECS services are RUNNING",
      "Verify no recent deployment errors",
      "Confirm container startup logs show Ready",
      "Validate memory usage < 90% during startup"
    ]
  }
}
