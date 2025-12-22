# CloudWatch Dashboards Module

Legacy dashboards for system, service, and infrastructure views.

## Usage
```hcl
module "cloudwatch_dashboards" {
  source = "./modules/cloudwatch-dashboards"

  cluster_name            = var.ecs_cluster_name
  service_names           = var.monitored_services
  autoscaling_group_name  = module.ecs_cluster.autoscaling_group_name
  alarm_actions           = [module.cloudwatch_monitoring.sns_topic_arn]
  enable_cost_tracking    = var.enable_cost_tracking
  log_retention_days      = var.log_retention_days
  tags                    = local.common_tags
}
```
