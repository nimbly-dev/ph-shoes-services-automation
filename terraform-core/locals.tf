locals {
  common_tags = merge({
    Application  = var.application_name
    Project      = "ph-shoes"
    Environment  = "beta"
    Stage        = "development"
    Owner        = "nimbly-dev"
    CostCenter   = "development"
    BillingGroup = "ph-shoes-services-automation"
    Tier         = "free"
    ManagedBy    = "terraform"
  }, var.extra_tags)
}
