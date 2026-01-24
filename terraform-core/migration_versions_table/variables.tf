variable "table_name" {
  description = "Name of the migration versions table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the DynamoDB table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PROVISIONED"
}

variable "read_capacity" {
  description = "Read capacity units when using PROVISIONED billing"
  type        = number
  default     = 1
}

variable "write_capacity" {
  description = "Write capacity units when using PROVISIONED billing"
  type        = number
  default     = 1
}

variable "enable_point_in_time_recovery" {
  description = "Enable PITR backups for the migration table"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the DynamoDB table (must include Project/Env for IAM guardrails)"
  type        = map(string)
  default     = {}
}
