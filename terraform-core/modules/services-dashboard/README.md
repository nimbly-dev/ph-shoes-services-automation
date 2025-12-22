# Services Dashboard Module

Focused CloudWatch dashboard for service memory and log access.

## Features
- Memory utilization widget and thresholds.
- One-click CloudWatch Logs links per service.
- Recent error log view and running task status.

## Usage
```hcl
module "services_dashboard" {
  source = "./modules/services-dashboard"

  cluster_name           = var.ecs_cluster_name
  service_names          = var.monitored_services
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name

  memory_thresholds = {
    normal   = 70
    warning  = 80
    critical = 95
  }

  tags = local.common_tags
}
```
