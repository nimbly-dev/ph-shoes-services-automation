locals {
  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    Application = var.app_name
    ManagedBy   = "terraform"
    Owner       = var.owner
  }, var.extra_tags)
}
