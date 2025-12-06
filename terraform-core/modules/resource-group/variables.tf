variable "name" {
  description = "Name for the AWS Resource Group"
  type        = string
}

variable "description" {
  description = "Optional description"
  type        = string
  default     = ""
}

variable "tag_query" {
  description = "Tag filters that define group membership"
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to the Resource Group itself"
  type        = map(string)
  default     = {}
}
