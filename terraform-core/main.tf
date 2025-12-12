

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
}

module "state_backend" {
  source = "./modules/state-backend"

  bucket_name            = var.state_bucket_name
  create_bucket          = var.create_state_bucket
  dynamodb_table_name    = var.state_lock_table_name
  dynamodb_read_capacity = var.state_lock_read_capacity
  dynamodb_write_capacity = var.state_lock_write_capacity
  tags                   = local.common_tags
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

data "aws_route53_zone" "frontend" {
  name         = "phshoesproject.com"
  private_zone = false
}

module "network" {
  source = "./modules/network"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  tags                = local.common_tags
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name            = var.ecs_cluster_name
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.public_subnet_ids
  instance_type           = var.ecs_instance_type
  min_size                = var.ecs_min_size
  max_size                = var.ecs_max_size
  desired_capacity        = var.ecs_desired_capacity
  key_name                = var.ecs_instance_key_name
  instance_volume_size    = var.ecs_instance_volume_size
  instance_ingress_rules  = var.ecs_instance_ingress_rules
  tags                    = local.common_tags
}

# Allow HTTP traffic for frontend (managed by workflow)
resource "aws_security_group_rule" "frontend_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ecs_cluster.instance_security_group_id
}


