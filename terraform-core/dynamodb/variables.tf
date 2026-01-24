variable "aws_region" {
  type        = string
  description = "AWS region to build ARNs"
}

variable "service_name" {
  type        = string
  description = "Logical name for the role (e.g., service-account)"
  default     = "service-account"
}

variable "project_tag" {
  type        = string
  description = "Project tag required on CreateTable / ResourceTag for ops"
  default     = "PH-Shoes"
}

variable "env_tag" {
  type        = string
  description = "Environment tag required on CreateTable / ResourceTag for ops"
  default     = "dev"
}

variable "allow_table_delete" {
  type        = bool
  description = "Allow DeleteTable (usually false in prod)"
  default     = false
}

variable "runtime" {
  type        = string
  description = "Where the role is assumed: ecs | ec2 | lambda"
  default     = "ecs"
  validation {
    condition     = contains(["ecs", "ec2", "lambda"], var.runtime)
    error_message = "runtime must be one of: ecs, ec2, lambda."
  }
}

variable "extra_data_actions" {
  type        = list(string)
  description = "Optional extra DynamoDB actions for data ops"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to the IAM role/policy"
  default     = {}
}
