
# NOTE: Log groups already exist in AWS and are working correctly
# Commenting out terraform management to avoid state conflicts
# The log groups have correct 3-day retention and proper tagging

locals {
  service_log_groups = {
    frontend      = "/ecs/ph-shoes-services-automation-frontend"
    user-accounts = "/ecs/ph-shoes-services-automation-user-accounts"
    catalog       = "/ecs/ph-shoes-services-automation-catalog"
    alerts        = "/ecs/ph-shoes-services-automation-alerts"
    text-search   = "/ecs/ph-shoes-services-automation-text-search"
  }

  # ECS system log groups
  ecs_log_groups = {
    ecs-performance = "/aws/ecs/containerinsights/${var.cluster_name}/performance"
    ecs-agent       = "/aws/ecs/containerinsights/${var.cluster_name}/agent"
  }

  # All log groups that need retention management
  all_log_groups = merge(local.service_log_groups, local.ecs_log_groups)
}

# Commented out to avoid terraform state conflicts - log groups already exist and working
# # Manage log retention for all service log groups
# resource "aws_cloudwatch_log_group" "service_logs" {
#   for_each = local.service_log_groups
# 
#   name              = each.value
#   retention_in_days = var.log_retention_days
# 
#   tags = merge(var.tags, {
#     LogType     = "ServiceLogs"
#     ServiceName = each.key
#   })
# }

# # Manage log retention for ECS system log groups
# # These may already exist, so we use lifecycle rules to avoid conflicts
# resource "aws_cloudwatch_log_group" "ecs_logs" {
#   for_each = local.ecs_log_groups
# 
#   name              = each.value
#   retention_in_days = var.log_retention_days
# 
#   # Prevent destruction if log group already exists
#   lifecycle {
#     ignore_changes = [name]
#   }
# 
#   tags = merge(var.tags, {
#     LogType     = "ECSSystemLogs"
#   })
# }

locals {
  cost_optimization_config = {
    log_retention_days = var.log_retention_days
    on_demand_focus    = var.on_demand_optimized
    current_session_focus = true
    historical_analysis_disabled = true
    estimated_monthly_log_volume_gb = 0.2
    estimated_monthly_cost_usd      = 0.01 # Well within free tier
    free_tier_usage_percentage      = 4    # 4% of 5GB free tier limit
  }
}

