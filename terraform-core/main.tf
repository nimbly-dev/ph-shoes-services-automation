

locals {
  frontend_repo_objects = [
    for name in var.frontend_repositories : {
      name        = name
      description = "Frontend SPA Docker image for ${name}"
    }
  ]

  backend_repo_objects = [
    for name in var.backend_web_modules : {
      name        = name
      description = "Spring Boot web module image for ${name}"
    }
  ]

  ecr_public_repositories = concat(
    local.frontend_repo_objects,
    local.backend_repo_objects,
    var.additional_ecr_repositories,
  )

  extraction_account_tags = {
    Project = var.extraction_project_tag
    Service = var.extraction_service_name
    Env     = var.extraction_env_tag
  }

  extraction_tags = merge(
    {
      Project   = var.extraction_project_tag
      Service   = var.extraction_service_name
      Env       = var.extraction_env_tag
      ManagedBy = "terraform"
    },
    var.extraction_extra_tags
  )

  extraction_tags_with_app = merge(
    local.extraction_tags,
    { Application = var.extraction_app_name }
  )
}

module "state_backend" {
  source = "./modules/state-backend"

  bucket_name             = var.state_bucket_name
  create_bucket           = var.create_state_bucket
  dynamodb_table_name     = var.state_lock_table_name
  dynamodb_read_capacity  = var.state_lock_read_capacity
  dynamodb_write_capacity = var.state_lock_write_capacity
  tags                    = local.common_tags
}

module "project_resource_group" {
  source = "./modules/resource-group"

  name        = var.project_name
  description = "Resource group that captures all ${var.project_name} assets"

  tag_query = {
    Project     = var.project_name
    Environment = var.environment
  }

  tags = local.common_tags
}

module "app_registry_application" {
  source = "./modules/appregistry-application"

  name        = var.application_name
  description = var.application_description
  tags        = local.common_tags
}

module "public_ecr_repositories" {
  source    = "./modules/ecr-public"
  providers = { aws = aws.ecr_public }

  repositories = local.ecr_public_repositories
  tags         = local.common_tags
}

module "github_oidc_role" {
  source = "./modules/github-oidc-role"

  role_name                  = var.github_oidc_role_name
  github_owner               = var.github_owner
  github_repositories        = var.github_repositories
  github_subjects            = var.github_subjects
  create_oidc_provider       = var.create_oidc_provider
  existing_oidc_provider_arn = var.existing_oidc_provider_arn
  attach_ecr_public_policy   = var.attach_ecr_public_policy
  additional_policy_json     = var.additional_iam_policy_json
  managed_policy_arns        = var.github_oidc_managed_policy_arns
  tags                       = local.common_tags
}

module "network" {
  source = "./modules/network"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  tags                = local.common_tags
}

module "backend_iam_roles" {
  source = "./modules/backend-iam-roles"

  name_prefix = var.project_name
  tags        = local.common_tags
}

module "frontend_iam_roles" {
  source = "./modules/frontend-iam-roles"

  name_prefix = var.project_name
  tags        = local.common_tags
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name           = var.ecs_cluster_name
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.public_subnet_ids
  instance_type          = var.ecs_instance_type
  min_size               = var.ecs_min_size
  max_size               = var.ecs_max_size
  desired_capacity       = var.ecs_desired_capacity
  key_name               = var.ecs_instance_key_name
  instance_volume_size   = var.ecs_instance_volume_size
  instance_ingress_rules = var.ecs_instance_ingress_rules
  tags                   = local.common_tags
}

resource "aws_security_group_rule" "frontend_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ecs_cluster.instance_security_group_id
}

resource "aws_security_group_rule" "backend_services" {
  type              = "ingress"
  from_port         = 8082
  to_port           = 8085
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ecs_cluster.instance_security_group_id
}



module "cloudwatch_monitoring" {
  count  = var.enable_cloudwatch_monitoring ? 1 : 0
  source = "./modules/cloudwatch-monitoring"

  cluster_name           = var.ecs_cluster_name
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name
  service_names          = var.monitored_services
  cpu_threshold          = var.cloudwatch_cpu_threshold
  memory_threshold       = var.cloudwatch_memory_threshold
  alarm_email            = var.cloudwatch_alarm_email
  tags                   = local.common_tags

  depends_on = [module.ecs_cluster]
}
module "cloudwatch_dashboards" {
  count  = var.enable_cloudwatch_dashboards ? 1 : 0
  source = "./modules/cloudwatch-dashboards"

  cluster_name           = var.ecs_cluster_name
  service_names          = var.monitored_services
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name
  alarm_actions          = var.enable_cloudwatch_monitoring ? [module.cloudwatch_monitoring[0].sns_topic_arn] : []
  enable_cost_tracking   = var.enable_cost_tracking
  log_retention_days     = var.log_retention_days
  tags                   = local.common_tags

  depends_on = [module.ecs_cluster, module.cloudwatch_monitoring]
}

module "enhanced_cloudwatch_dashboard" {
  count  = var.enable_enhanced_cloudwatch_dashboard ? 1 : 0
  source = "./modules/enhanced-cloudwatch-dashboard"

  cluster_name                     = var.ecs_cluster_name
  service_names                    = var.monitored_services
  autoscaling_group_name           = module.ecs_cluster.autoscaling_group_name
  load_balancer_name               = var.enhanced_dashboard_load_balancer_name
  alarm_actions                    = var.enable_cloudwatch_monitoring ? [module.cloudwatch_monitoring[0].sns_topic_arn] : []
  log_retention_days               = var.enhanced_dashboard_log_retention_days
  dashboard_refresh_interval       = var.enhanced_dashboard_refresh_interval
  max_widget_count                 = var.enhanced_dashboard_max_widgets
  api_request_budget               = var.enhanced_dashboard_api_budget
  enable_cost_tracking             = var.enable_cost_tracking
  enable_free_tier_monitoring      = var.enable_enhanced_free_tier_monitoring
  enable_security_monitoring       = var.enable_enhanced_security_monitoring
  enable_ecs_deployment_monitoring = var.enable_enhanced_ecs_monitoring
  query_optimization_enabled       = var.enable_enhanced_query_optimization
  log_sampling_rate                = var.enhanced_dashboard_log_sampling_rate

  tags = local.common_tags

  depends_on = [module.ecs_cluster, module.cloudwatch_monitoring]
}
module "services_dashboard" {
  count  = var.enable_services_dashboard ? 1 : 0
  source = "./modules/services-dashboard"

  cluster_name           = var.ecs_cluster_name
  service_names          = var.monitored_services
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name
  memory_thresholds = {
    normal   = var.services_dashboard_memory_normal_threshold
    warning  = var.services_dashboard_memory_warning_threshold
    critical = var.services_dashboard_memory_critical_threshold
  }
  log_retention_days         = var.services_dashboard_log_retention_days
  dashboard_refresh_interval = var.services_dashboard_refresh_interval
  on_demand_optimized        = var.services_dashboard_on_demand_optimized

  tags = local.common_tags

  depends_on = [module.ecs_cluster]
}
module "deployment_dashboard" {
  count  = var.enable_deployment_dashboard ? 1 : 0
  source = "./modules/deployment-dashboard"

  cluster_name               = var.ecs_cluster_name
  service_names              = var.monitored_services
  autoscaling_group_name     = module.ecs_cluster.autoscaling_group_name
  deployment_timeout_minutes = var.deployment_dashboard_timeout_minutes
  startup_timeout_minutes    = var.deployment_dashboard_startup_timeout_minutes
  memory_startup_threshold   = var.deployment_dashboard_memory_startup_threshold
  log_retention_days         = var.deployment_dashboard_log_retention_days
  dashboard_refresh_interval = var.deployment_dashboard_refresh_interval
  on_demand_optimized        = var.deployment_dashboard_on_demand_optimized
  enable_deployment_alarms   = var.deployment_dashboard_enable_alarms

  tags = local.common_tags

  depends_on = [module.ecs_cluster]
}
module "log_retention_management" {
  source = "./modules/log-retention-management"

  cluster_name        = var.ecs_cluster_name
  log_retention_days  = var.log_retention_days
  on_demand_optimized = true
  tags                = local.common_tags
}
module "simplified_cloudwatch_queries" {
  count  = var.enable_simplified_cloudwatch_queries ? 1 : 0
  source = "./modules/simplified-cloudwatch-queries"

  cluster_name              = var.ecs_cluster_name
  log_retention_days        = var.log_retention_days
  enable_startup_monitoring = var.simplified_queries_enable_startup_monitoring
  enable_error_monitoring   = var.simplified_queries_enable_error_monitoring

  tags = local.common_tags

  depends_on = [module.ecs_cluster]
}

module "account_iam" {
  source = "./dynamodb"

  aws_region   = var.aws_region
  service_name = var.extraction_service_name
  project_tag  = var.extraction_project_tag
  env_tag      = var.extraction_env_tag

  runtime            = var.extraction_runtime
  allow_table_delete = var.extraction_allow_table_delete

  tags = local.extraction_account_tags
}

module "ses_send" {
  source                   = "./ses"
  aws_region               = var.aws_region
  service_name             = var.extraction_service_name
  attach_to_role_name      = module.account_iam.role_name
  restrict_to_region       = true
  enable_event_destination = var.extraction_ses_enable_event_destination
  configuration_set_name   = var.extraction_ses_configuration_set_name
  event_destination_name   = var.extraction_ses_event_destination_name
  sns_topic_name           = var.extraction_ses_sns_topic_name
  webhook_endpoint         = var.extraction_ses_webhook_endpoint
  matching_event_types     = var.extraction_ses_matching_event_types
  tags                     = local.extraction_tags_with_app
}

module "domain" {
  source = "./domain"

  zone_name         = var.extraction_domain_zone_name
  render_www_target = var.extraction_render_www_target
  create_root_a     = var.extraction_create_root_a
  root_a_ip         = var.extraction_root_a_ip
  additional_cnames = var.extraction_additional_cnames

  manage_ses = var.extraction_manage_ses
  ses_domain = var.extraction_ses_domain

  create_mail_from    = var.extraction_create_mail_from
  mail_from_subdomain = var.extraction_mail_from_subdomain

  tags = local.extraction_tags
}

module "user_accounts_service_iam" {
  source      = "./user_accounts_service_iam"
  name_prefix = var.extraction_accounts_service_name_prefix
  env         = var.extraction_env_tag
  aws_region  = var.aws_region

  project_tag = var.extraction_project_tag
  env_tag     = var.extraction_env_tag

  ses_from_address    = var.extraction_accounts_service_ses_from_address
  create_access_key   = var.extraction_accounts_service_create_access_key
  include_env_in_name = var.extraction_accounts_service_include_env_in_name
  name_override       = var.extraction_accounts_service_name_override
  tags                = local.extraction_tags
}

module "migration_versions_table" {
  source = "./migration_versions_table"

  table_name                    = var.extraction_migrations_table_name
  billing_mode                  = var.extraction_migration_table_billing_mode
  read_capacity                 = var.extraction_migration_table_read_capacity
  write_capacity                = var.extraction_migration_table_write_capacity
  enable_point_in_time_recovery = var.extraction_migration_table_enable_point_in_time_recovery
  tags                          = local.extraction_tags
}





