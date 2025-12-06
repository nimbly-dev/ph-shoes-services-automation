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

variable "frontend_enable" {
  description = "Whether to provision the frontend ECS service + ALB"
  type        = bool
  default     = false
}

variable "frontend_container_image" {
  description = "Container image for the frontend SPA service"
  type        = string
  default     = ""
}

variable "frontend_container_port" {
  description = "Frontend container port exposed to the ALB"
  type        = number
  default     = 80
}

variable "frontend_desired_count" {
  description = "Desired task count for the frontend service"
  type        = number
  default     = 0
}

variable "frontend_cpu" {
  type    = number
  default = 256
}

variable "frontend_memory" {
  type    = number
  default = 512
}

variable "frontend_environment" {
  description = "Map of environment variables injected into the frontend"
  type        = map(string)
  default     = {}
}

variable "frontend_secrets" {
  description = "List of secrets for the frontend container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "frontend_domain_name" {
  description = "Root domain (e.g., phshoesproject.com)"
  type        = string
  default     = "phshoesproject.com"
}

variable "frontend_record_name" {
  description = "Record name ('' for apex, e.g., 'www')"
  type        = string
  default     = ""
}

variable "frontend_health_check_path" {
  description = "ALB health check path"
  type        = string
  default     = "/"
}

variable "vpc_cidr" {
  description = "CIDR block for the ECS VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (must match AZ count)"
  type        = list(string)
  default     = ["10.50.1.0/24", "10.50.2.0/24"]
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
  default = 2
}

variable "ecs_desired_capacity" {
  type    = number
  default = 2
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
