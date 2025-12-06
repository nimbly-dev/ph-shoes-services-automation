variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_arn" {
  description = "Target ECS cluster ARN"
  type        = string
}

variable "capacity_provider_name" {
  description = "Capacity provider used by the service"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for tasks"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "container_image" {
  description = "Container image URI"
  type        = string
}

variable "container_port" {
  description = "Container/listener port"
  type        = number
}

variable "cpu" {
  description = "Task CPU units"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 1024
}

variable "desired_count" {
  type    = number
  default = 0
}

variable "assign_public_ip" {
  description = "Assign a public IP to each task"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Plain-text environment variables"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "List of secrets passed to the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "ingress_rules" {
  description = "Ingress rules for the service security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ingress_security_group_map" {
  description = "Map of security groups allowed to reach the service keyed by a stable name"
  type        = map(string)
  default     = {}
}

variable "additional_security_group_ids" {
  description = "Additional security groups attached to the service ENIs"
  type        = list(string)
  default     = []
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 14
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "enable_execute_command" {
  type    = bool
  default = true
}

variable "task_role_inline_policy_json" {
  description = "Optional inline policy attached to the task role"
  type        = string
  default     = null
}

variable "task_role_managed_policy_arns" {
  description = "Managed policies attached to the task role"
  type        = list(string)
  default     = []
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 50
}

variable "deployment_maximum_percent" {
  type    = number
  default = 200
}

variable "health_check_grace_period_seconds" {
  type    = number
  default = 60
}

variable "force_new_deployment" {
  type    = bool
  default = false
}

variable "target_group_arn" {
  description = "Optional ALB/NLB target group ARN to register"
  type        = string
  default     = ""
}
