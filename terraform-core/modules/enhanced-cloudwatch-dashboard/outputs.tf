# Outputs for Enhanced CloudWatch Dashboard Module
# Comprehensive observability platform URLs and resource information

output "enhanced_dashboard_url" {
  description = "URL for the Enhanced Observability Dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.enhanced_observability.dashboard_name}"
}

output "enhanced_dashboard_name" {
  description = "Name of the enhanced observability dashboard"
  value       = aws_cloudwatch_dashboard.enhanced_observability.dashboard_name
}

output "query_definition_names" {
  description = "List of CloudWatch Insights query definition names for enhanced observability"
  value = [
    aws_cloudwatch_query_definition.critical_errors.name,
    aws_cloudwatch_query_definition.error_patterns.name,
    aws_cloudwatch_query_definition.stack_trace_analysis.name,
    aws_cloudwatch_query_definition.frontend_service_logs.name,
    aws_cloudwatch_query_definition.backend_service_logs.name,
    aws_cloudwatch_query_definition.api_performance_analysis.name,
    aws_cloudwatch_query_definition.ecs_task_lifecycle.name,
    aws_cloudwatch_query_definition.deployment_timeline.name,
    aws_cloudwatch_query_definition.task_placement_analysis.name,
    aws_cloudwatch_query_definition.authentication_events.name,
    aws_cloudwatch_query_definition.api_security_events.name
  ]
}

output "log_group_names" {
  description = "List of managed log group names with optimized retention"
  value = [
    for log_group in aws_cloudwatch_log_group.service_log_groups : log_group.name
  ]
}

output "free_tier_usage_summary" {
  description = "Free tier usage summary for monitoring compliance"
  value = {
    dashboard_count                = 1 # Single enhanced dashboard
    estimated_widget_count         = var.max_widget_count
    log_retention_days             = var.log_retention_days
    estimated_monthly_api_requests = var.api_request_budget
    query_definitions_count        = 11 # Total query definitions created
  }
}

output "dashboard_panels_summary" {
  description = "Summary of dashboard panels and their widget counts"
  value = {
    error_tracking_panel = {
      widget_count = 8
      description  = "Error rates, drill-down links, severity ranking, and performance impact"
    }
    one_click_log_access_panel = {
      widget_count = 6
      description  = "Service log buttons, filters, time ranges, and search templates"
    }
    health_monitoring_panel = {
      widget_count = 6
      description  = "Metrics-log correlation, anomaly detection, and resource correlation"
    }
    security_events_panel = {
      widget_count = 4
      description  = "Authentication failures, API security, and investigation links"
    }
    ecs_deployment_panel = {
      widget_count = 8
      description  = "Deployment monitoring, task lifecycle, replica visualization, and timeline analysis"
    }
  }
}

output "cloudwatch_insights_query_urls" {
  description = "Direct URLs to CloudWatch Insights queries for quick access"
  value = {
    critical_errors       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.critical_errors.query_definition_id}')"
    error_patterns        = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.error_patterns.query_definition_id}')"
    stack_traces          = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.stack_trace_analysis.query_definition_id}')"
    frontend_logs         = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.frontend_service_logs.query_definition_id}')"
    backend_logs          = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.backend_service_logs.query_definition_id}')"
    api_performance       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.api_performance_analysis.query_definition_id}')"
    ecs_lifecycle         = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.ecs_task_lifecycle.query_definition_id}')"
    deployment_timeline   = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.deployment_timeline.query_definition_id}')"
    task_placement        = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.task_placement_analysis.query_definition_id}')"
    authentication_events = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.authentication_events.query_definition_id}')"
    api_security          = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:logs-insights$3FqueryDetail$3D~(queryId~'${aws_cloudwatch_query_definition.api_security_events.query_definition_id}')"
  }
}

output "free_tier_compliance_status" {
  description = "Free tier compliance status and safety margins"
  value = {
    dashboard_usage            = "1/10 (10% used)"
    estimated_metric_usage     = "${var.max_widget_count}/50 (${var.max_widget_count * 2}% used)"
    estimated_api_usage        = "${var.api_request_budget}/10000 (${var.api_request_budget / 100}% used)"
    log_retention_optimization = "${var.log_retention_days} days retention"
    safety_margins = {
      dashboard_buffer = "90% remaining"
      metric_buffer    = "${100 - (var.max_widget_count * 2)}% remaining"
      api_buffer       = "${100 - (var.api_request_budget / 100)}% remaining"
    }
  }
}

output "monitoring_alarm_names" {
  description = "List of monitoring alarm names for free tier usage tracking"
  value = [
    aws_cloudwatch_metric_alarm.dashboard_count_monitor.alarm_name,
    aws_cloudwatch_metric_alarm.api_request_monitor.alarm_name
  ]
}