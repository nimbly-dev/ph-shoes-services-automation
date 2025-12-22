# Simplified CloudWatch Queries Module

Creates a small set of saved CloudWatch Logs Insights queries.

## Queries
- `ecs-deployment-events`
- `container-startup-logs`

## Usage
```hcl
module "simplified_cloudwatch_queries" {
  source = "./modules/simplified-cloudwatch-queries"

  cluster_name = var.cluster_name
  tags         = var.tags

  log_retention_days        = 3
  enable_startup_monitoring = true
  enable_error_monitoring   = true
}
```
