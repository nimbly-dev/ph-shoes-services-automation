# Variables for Deployment Dashboard Module

variable "cluster_name" {
  description = "ECS cluster name for deployment dashboard configuration"
  type        = string
}

variable "service_names" {
  description = "List of ECS service names to monitor for deployments"
  type        = list(string)
  default     = ["frontend", "user-accounts", "catalog", "alerts", "text-search"]
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name for t3.micro instance monitoring during deployments"
  type        = string
}

variable "deployment_timeout_minutes" {
  description = "Maximum deployment time in minutes before considering failed"
  type        = number
  default     = 30

  validation {
    condition     = var.deployment_timeout_minutes >= 10 && var.deployment_timeout_minutes <= 60
    error_message = "Deployment timeout must be between 10 and 60 minutes."
  }
}

variable "startup_timeout_minutes" {
  description = "Maximum container startup time in minutes"
  type        = number
  default     = 10

  validation {
    condition     = var.startup_timeout_minutes >= 5 && var.startup_timeout_minutes <= 30
    error_message = "Startup timeout must be between 5 and 30 minutes."
  }
}

variable "memory_startup_threshold" {
  description = "Memory utilization threshold during startup (higher than normal operations)"
  type        = number
  default     = 90

  validation {
    condition     = var.memory_startup_threshold >= 70 && var.memory_startup_threshold <= 100
    error_message = "Memory startup threshold must be between 70 and 100 percent."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days (cost optimization)"
  type        = number
  default     = 3

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 7
    error_message = "Log retention must be between 1 and 7 days for cost optimization."
  }
}

variable "dashboard_refresh_interval" {
  description = "Dashboard refresh interval in seconds (API efficiency)"
  type        = number
  default     = 300 # 5 minutes

  validation {
    condition     = var.dashboard_refresh_interval >= 300
    error_message = "Dashboard refresh interval must be at least 300 seconds (5 minutes) for API efficiency."
  }
}

variable "on_demand_optimized" {
  description = "Enable on-demand optimization for portfolio deployment patterns"
  type        = bool
  default     = true
}

variable "enable_deployment_alarms" {
  description = "Enable deployment-related alarms (optional for portfolio projects)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to deployment dashboard resources"
  type        = map(string)
  default     = {}
}
