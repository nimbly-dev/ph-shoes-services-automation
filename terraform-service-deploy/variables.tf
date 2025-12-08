variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project prefix"
  type        = string
  default     = "ph-shoes-services-automation"
}

variable "service_id" {
  description = "Logical service identifier (e.g., frontend)"
  type        = string
  default     = "frontend"
}

variable "service_name" {
  description = "ECS service name"
  type        = string
  default     = "ph-shoes-services-automation-frontend"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "ph-shoes-services-ecs"
}

variable "container_image" {
  description = "Container image URI"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Task CPU"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired ECS task count"
  type        = number
  default     = 0
}

variable "environment" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "target_group_arn" {
  description = "Target group ARN (optional for backend services)"
  type        = string
  default     = ""
}

variable "log_group_name" {
  description = "Existing CloudWatch log group name"
  type        = string
}

variable "execution_role_arn" {
  description = "Existing execution IAM role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "Existing task IAM role ARN"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}


