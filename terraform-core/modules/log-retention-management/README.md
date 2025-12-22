# Log Retention Management Module

Configures log retention settings for ECS log groups.

## Usage
```hcl
module "log_retention_management" {
  source = "./modules/log-retention-management"

  cluster_name        = var.ecs_cluster_name
  log_retention_days  = 3
  on_demand_optimized = true
  tags                = local.common_tags
}
```
