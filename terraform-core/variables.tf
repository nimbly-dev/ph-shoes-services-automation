variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment label"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Logical application or service name"
  type        = string
  default     = "ph-shoes-services"
}

variable "project_name" {
  description = "Project tag used across the stack"
  type        = string
  default     = "ph-shoes-services-automation"
}

variable "application_name" {
  description = "Human-friendly AWS Applications console entry"
  type        = string
  default     = "ph-shoes-application-services"
}

variable "application_description" {
  description = "Optional description shown in the AWS Applications console"
  type        = string
  default     = "PH Shoes Render-to-ECS migration workloads"
}

variable "owner" {
  description = "Primary owner for tagging"
  type        = string
  default     = "nimbly"
}

variable "extra_tags" {
  description = "Optional additional tags"
  type        = map(string)
  default     = {}
}

variable "frontend_repositories" {
  description = "List of frontend image repositories to create in ECR Public"
  type        = list(string)
  default     = ["ph-shoes-data-spa-frontend"]
}

variable "backend_web_modules" {
  description = "Backend Spring Boot web modules that require public ECR repositories"
  type        = list(string)
  default = [
    "ph-shoes-alerts-service-web",
    "ph-shoes-catalog-service-web",
    "ph-shoes-text-search-service-web",
    "ph-shoes-user-accounts-service-web",
  ]
}

variable "additional_ecr_repositories" {
  description = "Optional extra repository definitions appended to the defaults"
  type        = list(object({
    name        = string
    description = optional(string)
  }))
  default = []
}

variable "github_owner" {
  description = "GitHub organization or user that hosts the workflows"
  type        = string
  default     = "nimbly"
}

variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume the deployment role"
  type        = list(string)
  default     = ["ph-shoes-services-automation"]
}

variable "github_subjects" {
  description = "Override subjects for the OIDC trust policy (e.g., repo:org/name:environment:*). Defaults to repo:<owner>/<repo>:*"
  type        = list(string)
  default     = []
}

variable "github_oidc_role_name" {
  description = "Name of the IAM role assumed by GitHub Actions"
  type        = string
  default     = "ph-shoes-github-oidc"
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider in this account"
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "If provided, reuse an existing OIDC provider instead of creating one"
  type        = string
  default     = ""
}

variable "attach_ecr_public_policy" {
  description = "Attach the default ECR Public push policy to the GitHub role"
  type        = bool
  default     = true
}

variable "additional_iam_policy_json" {
  description = "Additional IAM policy JSON (as string) attached inline to the GitHub role"
  type        = string
  default     = null
}
