# Variables for CloudWatch Dashboards Module

variable "cluster_name" {
  description = "ECS cluster name for dashboard configuration"
  type        = string
}

variable "service_names" {
  description = "List of ECS service names to include in dashboards"
  type        = list(string)
  default     = ["frontend", "user-accounts", "catalog", "alerts", "text-search"]
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name for infrastructure monitoring"
  type        = string
}

variable "alarm_actions" {
  description = "List of alarm action ARNs (SNS topics) for composite alarms"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to dashboard resources"
  type        = map(string)
  default     = {}
}

variable "enable_cost_tracking" {
  description = "Enable cost tracking widgets in dashboards"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}
