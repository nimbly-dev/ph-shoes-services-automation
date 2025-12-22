# Outputs for Services Dashboard Module

output "dashboard_name" {
  description = "Name of the Services Dashboard"
  value       = aws_cloudwatch_dashboard.services_dashboard.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the Services Dashboard"
  value       = aws_cloudwatch_dashboard.services_dashboard.dashboard_arn
}

output "dashboard_url" {
  description = "URL to access the Services Dashboard in AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.services_dashboard.dashboard_name}"
}

output "query_definition_names" {
  description = "List of CloudWatch Insights query definition names"
  value = [
    aws_cloudwatch_query_definition.container_logs_access.name,
    aws_cloudwatch_query_definition.recent_error_logs.name
  ]
}

output "query_definition_ids" {
  description = "List of CloudWatch Insights query definition IDs"
  value = [
    aws_cloudwatch_query_definition.container_logs_access.query_definition_id,
    aws_cloudwatch_query_definition.recent_error_logs.query_definition_id
  ]
}

output "service_log_groups" {
  description = "Map of service names to their CloudWatch log group names"
  value = {
    for service_key, service in local.services : service_key => service.log_group
  }
}

output "memory_thresholds" {
  description = "Configured memory thresholds for monitoring"
  value       = local.memory_thresholds
}

output "dashboard_widget_count" {
  description = "Number of widgets in the Services Dashboard"
  value       = 6
}

output "free_tier_usage_estimate" {
  description = "Estimated free tier usage for this dashboard"
  value = {
    dashboards = "1/10 (10%)"
    metrics    = "~4/50 (8%)"
    api_calls  = "~150/month (1.5%)"
    queries    = "2 saved queries"
  }
}
