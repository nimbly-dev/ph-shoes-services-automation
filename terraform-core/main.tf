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
  tags                       = local.common_tags
}
