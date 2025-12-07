provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = var.core_state_bucket
    key    = var.core_state_key
    region = var.aws_region
  }
}

locals {
  service_name = "${var.project_name}-${var.service_id}"
}

module "frontend_service" {
  source = "../terraform-core/modules/ecs-service"

  service_name           = local.service_name
  cluster_arn            = data.terraform_remote_state.core.outputs.ecs_cluster_arn
  capacity_provider_name = data.terraform_remote_state.core.outputs.ecs_capacity_provider_name
  subnet_ids             = data.terraform_remote_state.core.outputs.public_subnet_ids
  vpc_id                 = data.terraform_remote_state.core.outputs.vpc_id

  container_image = var.container_image
  container_port  = var.container_port
  cpu             = var.cpu
  memory          = var.memory
  desired_count   = var.desired_count

  environment     = var.environment
  secrets         = var.secrets
  assign_public_ip = true
  aws_region      = var.aws_region

  log_group_name     = var.log_group_name != "" ? var.log_group_name : try(data.terraform_remote_state.core.outputs.frontend_log_group_name, "")
  execution_role_arn = var.execution_role_arn != "" ? var.execution_role_arn : try(data.terraform_remote_state.core.outputs.frontend_execution_role_arn, "")
  task_role_arn      = var.task_role_arn != "" ? var.task_role_arn : try(data.terraform_remote_state.core.outputs.frontend_task_role_arn, "")

  target_group_arn = var.target_group_arn
  tags             = merge(data.terraform_remote_state.core.outputs.common_tags, var.extra_tags, {
    Service = var.service_id
  })
}

output "service_name" {
  value = module.frontend_service.service_name
}
