# Log Retention Management Module Outputs
# NOTE: Resources commented out to avoid terraform state conflicts

output "service_log_groups" {
  description = "Map of service log group names (resources exist but not managed by terraform)"
  value = {
    for k, v in local.service_log_groups : k => {
      name = v
      arn  = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${v}"
    }
  }
}

output "ecs_log_groups" {
  description = "Map of ECS system log group names (resources exist but not managed by terraform)"
  value = {
    for k, v in local.ecs_log_groups : k => {
      name = v
      arn  = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${v}"
    }
  }
}

output "cost_optimization_summary" {
  description = "Summary of cost optimization settings and estimated usage"
  value = {
    log_retention_days          = var.log_retention_days
    total_log_groups_managed    = length(local.service_log_groups) + length(local.ecs_log_groups)
    on_demand_optimized         = var.on_demand_optimized
    estimated_monthly_volume_gb = 0.2
    estimated_monthly_cost_usd  = 0.01
    free_tier_usage_percentage  = "4% of 5GB limit"

    optimization_features = {
      short_retention_period   = "${var.log_retention_days} days (vs 30+ days default)"
      current_session_focus    = "Optimized for on-demand usage"
      historical_analysis      = "Disabled to reduce costs"
      api_request_optimization = "5-minute refresh intervals"
    }
  }
}

output "log_group_names" {
  description = "List of all log group names for reference (exist but not terraform managed)"
  value = concat(
    [for k, v in local.service_log_groups : v],
    [for k, v in local.ecs_log_groups : v]
  )
}

# Add required data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
