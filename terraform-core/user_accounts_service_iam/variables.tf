variable "name_prefix" {
  description = "Prefix for naming IAM resources (e.g., ph-shoes)"
  type        = string
}

variable "env" {
  description = "Environment label (dev|stg|prod) — used in tags, not the name by default"
  type        = string
}

variable "aws_region" {
  description = "AWS region (e.g., ap-southeast-1)"
  type        = string
}

# Tag guards (match your /dynamodb module)
variable "project_tag" {
  description = "Project tag value required by ResourceTag conditions (e.g., PH-Shoes)"
  type        = string
}

variable "env_tag" {
  description = "Env tag value required by ResourceTag conditions (e.g., dev)"
  type        = string
}

variable "ddb_actions" {
  description = "DynamoDB data actions allowed on tagged tables (least-priv defaults)"
  type        = list(string)
  default = [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:BatchWriteItem",
    "dynamodb:BatchGetItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "dynamodb:ConditionCheckItem"
  ]
}

variable "ses_from_address" {
  description = "Verified SES From address in the same region (e.g., no-reply@phshoesproject.com)"
  type        = string
}

variable "create_access_key" {
  description = "Create an IAM access key for the service user"
  type        = bool
  default     = true
}


variable "include_env_in_name" {
  description = "Append -<env> to resource names if true"
  type        = bool
  default     = false
}

variable "name_override" {
  description = "Hard override for IAM user name; when non-empty, it is used verbatim"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Extra tags to merge into all resources"
  type        = map(string)
  default     = {}
}
