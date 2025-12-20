# Variables for Enhanced CloudWatch Dashboard Module
# Comprehensive observability platform with free tier optimization

variable "cluster_name" {
  description = "ECS cluster name for dashboard configuration"
  type        = string
}

variable "service_names" {
  description = "List of ECS service names to include in enhanced dashboard"
  type        = list(string)
  default     = ["frontend", "user-accounts", "catalog", "alerts", "text-search"]
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name for infrastructure monitoring"
  type        = string
}

variable "load_balancer_name" {
  description = "Application Load Balancer name for performance monitoring"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "List of alarm action ARNs (SNS topics) for enhanced monitoring alerts"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to enhanced dashboard resources"
  type        = map(string)
  default     = {}
}

variable "enable_cost_tracking" {
  description = "Enable cost tracking and free tier usage monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days (optimized for free tier)"
  type        = number
  default     = 3

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 7
    error_message = "Log retention must be between 1 and 7 days for free tier optimization."
  }
}

variable "enable_free_tier_monitoring" {
  description = "Enable free tier usage monitoring and alerts"
  type        = bool
  default     = true
}

variable "dashboard_refresh_interval" {
  description = "Dashboard auto-refresh interval in seconds (optimized for API usage)"
  type        = number
  default     = 300

  validation {
    condition     = var.dashboard_refresh_interval >= 300
    error_message = "Refresh interval must be at least 300 seconds (5 minutes) for free tier optimization."
  }
}

variable "max_widget_count" {
  description = "Maximum number of widgets to stay within free tier limits"
  type        = number
  default     = 32

  validation {
    condition     = var.max_widget_count <= 50
    error_message = "Widget count must not exceed 50 to stay within free tier metric limits."
  }
}

variable "enable_security_monitoring" {
  description = "Enable security event monitoring in the enhanced dashboard"
  type        = bool
  default     = true
}

variable "enable_ecs_deployment_monitoring" {
  description = "Enable ECS deployment and task lifecycle monitoring"
  type        = bool
  default     = true
}

variable "query_optimization_enabled" {
  description = "Enable query optimization features for free tier compliance"
  type        = bool
  default     = true
}

variable "log_sampling_rate" {
  description = "Log sampling rate for high-volume scenarios (0.1 = 10% sampling)"
  type        = number
  default     = 1.0

  validation {
    condition     = var.log_sampling_rate > 0 && var.log_sampling_rate <= 1
    error_message = "Log sampling rate must be between 0 and 1."
  }
}

variable "api_request_budget" {
  description = "Monthly API request budget for free tier compliance"
  type        = number
  default     = 2900

  validation {
    condition     = var.api_request_budget <= 10000
    error_message = "API request budget must not exceed 10,000 requests per month (free tier limit)."
  }
}