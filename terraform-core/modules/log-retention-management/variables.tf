# Log Retention Management Module Variables

variable "cluster_name" {
  description = "ECS cluster name for log group naming"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention period in days (optimized for cost: 3 days)"
  type        = number
  default     = 3

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 7
    error_message = "Log retention must be between 1 and 7 days for cost optimization."
  }
}

variable "on_demand_optimized" {
  description = "Enable on-demand optimization for portfolio usage patterns"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all log groups"
  type        = map(string)
  default     = {}
}
