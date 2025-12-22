
locals {
  # Service log groups
  services = {
    frontend      = { log_group = "/ecs/ph-shoes-services-automation-frontend", display_name = "Frontend SPA" }
    user-accounts = { log_group = "/ecs/ph-shoes-services-automation-user-accounts", display_name = "User Accounts Service" }
    catalog       = { log_group = "/ecs/ph-shoes-services-automation-catalog", display_name = "Catalog Service" }
    alerts        = { log_group = "/ecs/ph-shoes-services-automation-alerts", display_name = "Alerts Service" }
    text-search   = { log_group = "/ecs/ph-shoes-services-automation-text-search", display_name = "Text Search Service" }
  }

  # Query settings
  query_config = {
    recent_time_window  = "2 hour"
    startup_time_window = "30 minute"
    max_results         = 50
    deployment_window   = "1 hour"
  }
}
# Commented out - already exists in AWS and working correctly
# resource "aws_cloudwatch_query_definition" "container_logs_access" {
#   name = "${var.cluster_name}-container-logs-access"
# 
#   log_group_names = [for service in local.services : service.log_group]
# 
#   query_string = <<EOF
# fields @timestamp, @message, @logStream
# | filter @timestamp > date_sub(now(), interval ${local.query_config.recent_time_window})
# | sort @timestamp desc
# | limit ${local.query_config.max_results}
# EOF
# }
resource "aws_cloudwatch_query_definition" "ecs_deployment_events" {
  name = "${var.cluster_name}-ecs-deployment-events"

  log_group_names = ["/aws/ecs/containerinsights/${var.cluster_name}/performance"]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /deployment/ or @message like /service/ or @message like /task/
| filter @timestamp > date_sub(now(), interval ${local.query_config.deployment_window})
| sort @timestamp desc
| limit ${local.query_config.max_results}
EOF
}
# Commented out - already exists in AWS and working correctly
# resource "aws_cloudwatch_query_definition" "recent_error_logs" {
#   name = "${var.cluster_name}-recent-error-logs"
# 
#   log_group_names = [for service in local.services : service.log_group]
# 
#   query_string = <<EOF
# fields @timestamp, @message, @logStream
# | filter @message like /ERROR/ or @message like /Exception/ or @message like /FATAL/
# | filter @timestamp > date_sub(now(), interval ${local.query_config.recent_time_window})
# | sort @timestamp desc
# | limit 25
# EOF
# }
resource "aws_cloudwatch_query_definition" "container_startup_logs" {
  name = "${var.cluster_name}-container-startup-logs"

  log_group_names = [for service in local.services : service.log_group]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /Starting/ or @message like /Started/ or @message like /Initializing/ or @message like /Ready/ or @message like /Listening/
| filter @timestamp > date_sub(now(), interval ${local.query_config.startup_time_window})
| sort @timestamp desc
| limit 20
EOF
}


