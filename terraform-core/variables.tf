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
  default     = "nimbly-dev"
}

variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume the deployment role"
  type        = list(string)
  default     = [
    "ph-shoes-services-automation",
    "ph-shoes-data-spa",
    "ph-shoes-catalog-service",
    "ph-shoes-alerts-service",
    "ph-shoes-user-accounts-service",
    "ph-shoes-search-services",
    "ph-shoes-notification-service",
  ]
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

variable "github_oidc_managed_policy_arns" {
  description = "Managed IAM policy ARNs attached to the GitHub deployment role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state"
  type        = string
  default     = "ph-shoes-terraform-state"
}

variable "create_state_bucket" {
  description = "Create/manage the S3 bucket within this stack"
  type        = bool
  default     = false
}

variable "state_lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "ph-shoes-terraform-locks"
}

variable "state_lock_read_capacity" {
  description = "Provisioned read capacity for the lock table"
  type        = number
  default     = 1
}

variable "state_lock_write_capacity" {
  description = "Provisioned write capacity for the lock table"
  type        = number
  default     = 1
}

variable "vpc_cidr" {
  description = "CIDR block for the ECS VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (must match AZ count)"
  type        = list(string)
  default     = ["10.50.1.0/24"]
}

variable "availability_zones" {
  description = "Optional AZ override for the subnets"
  type        = list(string)
  default     = []
}

variable "ecs_cluster_name" {
  description = "Name of the shared ECS cluster"
  type        = string
  default     = "ph-shoes-services-ecs"
}

variable "ecs_instance_type" {
  description = "EC2 instance type for ECS hosts"
  type        = string
  default     = "t3.micro"
}

variable "ecs_min_size" {
  type    = number
  default = 1
}

variable "ecs_max_size" {
  type    = number
  default = 3
}

variable "ecs_desired_capacity" {
  type    = number
  default = 1
}

variable "ecs_instance_key_name" {
  description = "Optional SSH key for ECS instances"
  type        = string
  default     = ""
}

variable "ecs_instance_volume_size" {
  description = "Root volume size for ECS instances (GB)"
  type        = number
  default     = 30
}

variable "ecs_instance_ingress_rules" {
  description = "Ingress rules for ECS instance security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "frontend_memory_mb" {
  description = "Memory allocation for frontend services in MB"
  type        = number
  default     = 128
}

variable "backend_memory_mb" {
  description = "Memory allocation for backend services in MB"
  type        = number
  default     = 456
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}

# Cloudflare variables
variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS management"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for phshoesproject.com"
  type        = string
  default     = ""
}

variable "use_cloudflare_dns" {
  description = "Use Cloudflare for DNS management instead of Route53"
  type        = bool
  default     = false
}


