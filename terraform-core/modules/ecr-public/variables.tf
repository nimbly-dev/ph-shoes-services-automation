variable "repositories" {
  description = "List of ECR Public repositories to create"
  type = list(object({
    name        = string
    description = optional(string)
  }))
}

variable "tags" {
  description = "Tags applied to each repository"
  type        = map(string)
  default     = {}
}
