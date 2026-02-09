# Variables for Services Dashboard Module

variable "cluster_name" {
  description = "ECS cluster name for dashboard configuration"
  type        = string
}

variable "service_names" {
  description = "List of ECS service names to monitor"
  type        = list(string)
  default     = ["frontend", "user-accounts", "catalog", "alerts", "text-search"]
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name for t3.micro instance monitoring"
  type        = string
}

variable "memory_thresholds" {
  description = "Memory utilization thresholds for visual indicators"
  type = object({
    normal   = number
    warning  = number
    critical = number
  })
  default = {
    normal   = 70 # Green indicator
    warning  = 80 # Yellow indicator
    critical = 95 # Red indicator
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days (cost optimization)"
  type        = number
  default     = 3
}

variable "dashboard_refresh_interval" {
  description = "Dashboard refresh interval in seconds (API efficiency)"
  type        = number
  default     = 300 # 5 minutes
}

variable "on_demand_optimized" {
  description = "Enable on-demand optimization for portfolio usage patterns"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to dashboard resources"
  type        = map(string)
  default     = {}
}
