locals {
  env_list = [
    for key, value in var.environment : {
      name  = key
      value = value
    }
  ]

  has_custom_ingress = length(var.ingress_rules) > 0
  default_ingress = local.has_custom_ingress ? [] : [
    {
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  ingress_rules = concat(var.ingress_rules, local.default_ingress)
}

resource "aws_cloudwatch_log_group" "service" {
  count             = var.log_group_name == "" ? 1 : 0
  name              = local.default_log_group_name
  retention_in_days = var.log_retention_in_days
  tags = merge(var.tags, {
    ServiceName = var.service_name
    ServiceType = var.service_type
  })
}

resource "aws_security_group" "service" {
  name        = "${var.service_name}-sg"
  description = "Security group for ${var.service_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {
    Name        = "${var.service_name}-sg"
    ServiceName = var.service_name
    ServiceType = var.service_type
  })
}

resource "aws_iam_role" "execution" {
  count = var.execution_role_arn == "" ? 1 : 0
  name  = "${var.service_name}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = merge(var.tags, {
    ServiceName = var.service_name
    ServiceType = var.service_type
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  count      = var.execution_role_arn == "" ? 1 : 0
  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  count = var.task_role_arn == "" ? 1 : 0
  name  = "${var.service_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = merge(var.tags, {
    ServiceName = var.service_name
    ServiceType = var.service_type
  })
}

resource "aws_iam_role_policy_attachment" "task_managed" {
  count      = var.task_role_arn == "" ? length(var.task_role_managed_policy_arns) : 0
  role       = aws_iam_role.task[0].name
  policy_arn = var.task_role_managed_policy_arns[count.index]
}

resource "aws_iam_role_policy" "task_inline" {
  count  = var.task_role_arn == "" && var.task_role_inline_policy_json != null ? 1 : 0
  name   = "${var.service_name}-inline"
  role   = aws_iam_role.task[0].id
  policy = var.task_role_inline_policy_json
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = local.env_list
      secrets     = var.secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.service_name
        }
      }
    }
  ])
}

locals {
  # Determine log group naming convention based on service type
  is_frontend_service    = var.service_type == "frontend"
  default_log_group_name = local.is_frontend_service ? "/frontend" : "/backend/${var.service_name}"

  log_group_name     = var.log_group_name != "" ? var.log_group_name : aws_cloudwatch_log_group.service[0].name
  execution_role_arn = var.execution_role_arn != "" ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn      = var.task_role_arn != "" ? var.task_role_arn : aws_iam_role.task[0].arn
  assign_public_ip   = var.launch_type == "FARGATE" ? var.assign_public_ip : false
}

resource "aws_ecs_service" "this" {
  name                               = var.service_name
  cluster                            = var.cluster_arn
  desired_count                      = var.desired_count
  task_definition                    = aws_ecs_task_definition.this.arn
  enable_execute_command             = var.enable_execute_command
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  force_new_deployment               = var.force_new_deployment
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
  }


  dynamic "load_balancer" {
    for_each = var.target_group_arn == "" ? [] : [var.target_group_arn]
    content {
      target_group_arn = load_balancer.value
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    ServiceName = var.service_name
    ServiceType = var.service_type
  })
}
