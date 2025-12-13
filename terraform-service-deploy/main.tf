provider "aws" {
  region = var.aws_region
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = 14
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
    base              = 0
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  enable_execute_command = true

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = var.container_image
    cpu       = var.cpu
    memory    = var.memory
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
    environment = [for k, v in var.environment : { name = k, value = v }]
    secrets     = var.secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = var.service_name
      }
    }
  }])
}

resource "null_resource" "force_deployment" {
  triggers = {
    task_definition_arn = aws_ecs_task_definition.this.arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ecs update-service \
        --cluster ${data.aws_ecs_cluster.this.cluster_name} \
        --service ${var.service_name} \
        --task-definition ${aws_ecs_task_definition.this.family}:${aws_ecs_task_definition.this.revision} \
        --force-new-deployment \
        --region ${var.aws_region}
    EOT
  }

  depends_on = [aws_ecs_service.this, aws_ecs_task_definition.this]
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_definition_revision" {
  value = aws_ecs_task_definition.this.revision
}
