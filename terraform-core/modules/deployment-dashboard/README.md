# Deployment Dashboard Module

Focused CloudWatch dashboard for ECS deployments and startup logs.

## Features
- Deployment status and startup log widgets.
- One-click links to ECS services and logs.
- Memory during startup view.

## Usage
```hcl
module "deployment_dashboard" {
  source = "./modules/deployment-dashboard"

  cluster_name           = var.ecs_cluster_name
  service_names          = var.monitored_services
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name

  deployment_timeout_minutes = 30
  startup_timeout_minutes    = 10
  memory_startup_threshold   = 90

  log_retention_days         = 3
  dashboard_refresh_interval = 300
  on_demand_optimized        = true

  tags = local.common_tags
}
```
