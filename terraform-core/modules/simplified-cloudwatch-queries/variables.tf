# Variables for Simplified CloudWatch Queries Module

variable "cluster_name" {
  description = "Name of the ECS cluster for query naming and log group references"
  type        = string
}

variable "tags" {
  description = "Tags to apply to CloudWatch query resources"
  type        = map(string)
  default     = {}
}

# Optional variables for query customization
variable "log_retention_days" {
  description = "Log retention period in days for cost optimization"
  type        = number
  default     = 3
}

variable "enable_startup_monitoring" {
  description = "Enable container startup monitoring queries"
  type        = bool
  default     = true
}

variable "enable_error_monitoring" {
  description = "Enable simplified error log monitoring"
  type        = bool
  default     = true
}
