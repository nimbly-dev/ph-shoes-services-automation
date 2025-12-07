variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "create_bucket" {
  description = "Whether to create/manage the S3 bucket"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
  type        = string
}

variable "dynamodb_read_capacity" {
  description = "Provisioned read capacity units"
  type        = number
  default     = 1
}

variable "dynamodb_write_capacity" {
  description = "Provisioned write capacity units"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to backend resources"
  type        = map(string)
  default     = {}
}
