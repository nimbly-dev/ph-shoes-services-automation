provider "aws" {
  region = var.aws_region
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_ecs_service" "this" {
  service_name = var.service_name
  cluster_arn  = data.aws_ecs_cluster.this.arn
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
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
    task_definition = aws_ecs_task_definition.this.arn
    image           = var.container_image
    timestamp       = timestamp()
  }

  provisioner "local-exec" {
    command = "aws ecs update-service --cluster ${data.aws_ecs_cluster.this.cluster_name} --service ${var.service_name} --task-definition ${aws_ecs_task_definition.this.family}:${aws_ecs_task_definition.this.revision} --force-new-deployment --region ${var.aws_region}"
  }
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}
