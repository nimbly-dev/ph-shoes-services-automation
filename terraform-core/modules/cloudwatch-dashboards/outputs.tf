# Outputs for CloudWatch Dashboards Module

output "system_overview_dashboard_url" {
  description = "URL for the System Overview Dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.system_overview.dashboard_name}"
}

output "service_performance_dashboard_url" {
  description = "URL for the Service Performance Dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.service_performance.dashboard_name}"
}

output "infrastructure_dashboard_url" {
  description = "URL for the Infrastructure Dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.infrastructure.dashboard_name}"
}

output "dashboard_names" {
  description = "List of created dashboard names"
  value = [
    aws_cloudwatch_dashboard.system_overview.dashboard_name,
    aws_cloudwatch_dashboard.service_performance.dashboard_name,
    aws_cloudwatch_dashboard.infrastructure.dashboard_name
  ]
}

output "query_definition_names" {
  description = "List of CloudWatch Insights query definition names"
  value = [
    aws_cloudwatch_query_definition.container_logs_access.name,
    aws_cloudwatch_query_definition.ecs_deployment_events.name
  ]
}

output "composite_alarm_names" {
  description = "List of composite alarm names - removed for cost optimization"
  value       = []
}
