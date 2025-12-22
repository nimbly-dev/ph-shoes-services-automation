# Outputs for Simplified CloudWatch Queries Module

output "query_names" {
  description = "List of simplified CloudWatch Insights query definition names"
  value = [
    aws_cloudwatch_query_definition.ecs_deployment_events.name,
    aws_cloudwatch_query_definition.container_startup_logs.name
  ]
}

output "query_ids" {
  description = "List of simplified CloudWatch Insights query definition IDs"
  value = [
    aws_cloudwatch_query_definition.ecs_deployment_events.query_definition_id,
    aws_cloudwatch_query_definition.container_startup_logs.query_definition_id
  ]
}

output "essential_queries" {
  description = "Map of essential query names and their IDs for dashboard integration"
  value = {
    ecs_deployment_events  = aws_cloudwatch_query_definition.ecs_deployment_events.query_definition_id
    container_startup_logs = aws_cloudwatch_query_definition.container_startup_logs.query_definition_id
  }
}

output "query_urls" {
  description = "Direct URLs to CloudWatch Insights queries for one-click access"
  value = {
    ecs_deployment_events  = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.ecs_deployment_events.query_definition_id}')"
    container_startup_logs = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.container_startup_logs.query_definition_id}')"
  }
}

data "aws_region" "current" {}

# Summary of simplified queries vs complex queries removed
output "simplification_summary" {
  description = "Summary of query simplification for Task 7"
  value = {
    queries_kept               = 4
    queries_removed            = 13 # From enhanced-cloudwatch-dashboard module
    api_efficiency_improvement = "Reduced from 13 complex queries to 4 essential queries"
    free_tier_optimization     = "Optimized for on-demand usage with 2-hour time windows"
    removed_query_types = [
      "Error analysis queries (critical_errors, error_patterns, stack_trace_analysis)",
      "Security event queries (authentication_events, api_security_events)",
      "Performance analysis queries (api_performance_analysis, performance_anomaly_detection)",
      "Health correlation queries (health_status_correlation, resource_correlation_analysis, system_health_overview)",
      "Complex service queries (frontend_service_logs, backend_service_logs)",
      "Task placement analysis (task_placement_analysis)"
    ]
  }
}
