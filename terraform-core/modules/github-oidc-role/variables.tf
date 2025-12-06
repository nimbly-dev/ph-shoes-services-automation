variable "role_name" {
  description = "IAM role name assumed by GitHub Actions"
  type        = string
}

variable "github_owner" {
  description = "GitHub organization/user"
  type        = string
}

variable "github_repositories" {
  description = "Repositories allowed to assume the role"
  type        = list(string)
}

variable "github_subjects" {
  description = "Override sub claim patterns (e.g., repo:org/name:environment:prod)"
  type        = list(string)
  default     = []
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider"
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "Reuse an existing OIDC provider"
  type        = string
  default     = ""
}

variable "attach_ecr_public_policy" {
  description = "Attach default ECR Public push policy"
  type        = bool
  default     = true
}

variable "additional_policy_json" {
  description = "Optional extra inline policy JSON"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Managed policies to attach to the GitHub OIDC role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to IAM resources"
  type        = map(string)
  default     = {}
}
