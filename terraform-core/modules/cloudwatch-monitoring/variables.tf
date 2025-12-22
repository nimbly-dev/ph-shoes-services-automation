variable "cluster_name" {
  description = "ECS cluster name for monitoring"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name for instance failure monitoring"
  type        = string
}

variable "service_names" {
  description = "List of ECS service names to monitor (deprecated - not used in minimal alarm set)"
  type        = list(string)
  default     = []
}

variable "cpu_threshold" {
  description = "CPU utilization threshold percentage for alarms (deprecated - not used in minimal alarm set)"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold percentage for alarms (deprecated - not used in minimal alarm set)"
  type        = number
  default     = 80
}

variable "alarm_email" {
  description = "Email address for alarm notifications (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}
