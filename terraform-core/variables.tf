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
  default     = "ph-shoes-services"
}

variable "application_name" {
  description = "Human-friendly AWS Applications console entry"
  type        = string
  default     = "ph-shoes-services"
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
  type = list(object({
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
  default = [
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
  default     = 400
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}

# CloudWatch Monitoring variables
variable "enable_cloudwatch_monitoring" {
  description = "Enable CloudWatch monitoring and alarms for ECS services"
  type        = bool
  default     = true
}

variable "cloudwatch_cpu_threshold" {
  description = "CPU utilization threshold percentage for CloudWatch alarms"
  type        = number
  default     = 80
}

variable "cloudwatch_memory_threshold" {
  description = "Memory utilization threshold percentage for CloudWatch alarms"
  type        = number
  default     = 80
}

variable "cloudwatch_alarm_email" {
  description = "Email address for CloudWatch alarm notifications (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "monitored_services" {
  description = "List of ECS service names to monitor with CloudWatch alarms"
  type        = list(string)
  default = [
    "ph-shoes-alerts-service-web",
    "ph-shoes-catalog-service-web",
    "ph-shoes-text-search-service-web",
    "ph-shoes-user-accounts-service-web",
    "ph-shoes-data-spa-frontend"
  ]
}
variable "enable_cloudwatch_dashboards" {
  description = "Enable comprehensive CloudWatch dashboards for system monitoring"
  type        = bool
  default     = true
}

variable "enable_cost_tracking" {
  description = "Enable cost tracking widgets in CloudWatch dashboards"
  type        = bool
  default     = true
}


# Enhanced CloudWatch Dashboard variables
variable "enable_enhanced_cloudwatch_dashboard" {
  description = "Enable the enhanced CloudWatch dashboard with comprehensive observability features"
  type        = bool
  default     = true
}

variable "enhanced_dashboard_log_retention_days" {
  description = "Log retention period in days for enhanced dashboard (optimized for free tier: 1-7 days)"
  type        = number
  default     = 3

  validation {
    condition     = var.enhanced_dashboard_log_retention_days >= 1 && var.enhanced_dashboard_log_retention_days <= 7
    error_message = "Enhanced dashboard log retention must be between 1 and 7 days for free tier optimization."
  }
}

variable "enhanced_dashboard_refresh_interval" {
  description = "Dashboard auto-refresh interval in seconds (minimum 300 for free tier optimization)"
  type        = number
  default     = 300

  validation {
    condition     = var.enhanced_dashboard_refresh_interval >= 300
    error_message = "Enhanced dashboard refresh interval must be at least 300 seconds (5 minutes) for free tier optimization."
  }
}

variable "enhanced_dashboard_max_widgets" {
  description = "Maximum number of widgets in enhanced dashboard (maximum 50 for free tier compliance)"
  type        = number
  default     = 32

  validation {
    condition     = var.enhanced_dashboard_max_widgets <= 50
    error_message = "Enhanced dashboard widget count must not exceed 50 to stay within free tier metric limits."
  }
}

variable "enhanced_dashboard_api_budget" {
  description = "Monthly API request budget for enhanced dashboard (maximum 10,000 for free tier)"
  type        = number
  default     = 2900

  validation {
    condition     = var.enhanced_dashboard_api_budget <= 10000
    error_message = "Enhanced dashboard API request budget must not exceed 10,000 requests per month (free tier limit)."
  }
}

variable "enhanced_dashboard_load_balancer_name" {
  description = "Application Load Balancer name for enhanced dashboard performance monitoring (optional)"
  type        = string
  default     = ""
}

variable "enable_enhanced_free_tier_monitoring" {
  description = "Enable free tier usage monitoring and alerts for enhanced dashboard"
  type        = bool
  default     = true
}

variable "enable_enhanced_security_monitoring" {
  description = "Enable security event monitoring in the enhanced dashboard"
  type        = bool
  default     = true
}

variable "enable_enhanced_ecs_monitoring" {
  description = "Enable ECS deployment and task lifecycle monitoring in enhanced dashboard"
  type        = bool
  default     = true
}

variable "enable_enhanced_query_optimization" {
  description = "Enable query optimization features for enhanced dashboard free tier compliance"
  type        = bool
  default     = true
}

variable "enhanced_dashboard_log_sampling_rate" {
  description = "Log sampling rate for enhanced dashboard high-volume scenarios (0.1 = 10% sampling, 1.0 = 100%)"
  type        = number
  default     = 1.0

  validation {
    condition     = var.enhanced_dashboard_log_sampling_rate > 0 && var.enhanced_dashboard_log_sampling_rate <= 1
    error_message = "Enhanced dashboard log sampling rate must be between 0 and 1."
  }
}
variable "enable_services_dashboard" {
  description = "Enable the Services Dashboard for portfolio monitoring (focused on t3.micro memory and log access)"
  type        = bool
  default     = false
}

variable "services_dashboard_memory_normal_threshold" {
  description = "Memory utilization threshold for normal (green) status indicator"
  type        = number
  default     = 70

  validation {
    condition     = var.services_dashboard_memory_normal_threshold > 0 && var.services_dashboard_memory_normal_threshold <= 100
    error_message = "Services dashboard memory normal threshold must be between 0 and 100."
  }
}

variable "services_dashboard_memory_warning_threshold" {
  description = "Memory utilization threshold for warning (yellow) status indicator"
  type        = number
  default     = 80

  validation {
    condition     = var.services_dashboard_memory_warning_threshold > 0 && var.services_dashboard_memory_warning_threshold <= 100
    error_message = "Services dashboard memory warning threshold must be between 0 and 100."
  }
}

variable "services_dashboard_memory_critical_threshold" {
  description = "Memory utilization threshold for critical (red) status indicator"
  type        = number
  default     = 95

  validation {
    condition     = var.services_dashboard_memory_critical_threshold > 0 && var.services_dashboard_memory_critical_threshold <= 100
    error_message = "Services dashboard memory critical threshold must be between 0 and 100."
  }
}

variable "services_dashboard_log_retention_days" {
  description = "Log retention period in days for Services Dashboard (optimized for cost: 1-7 days)"
  type        = number
  default     = 3

  validation {
    condition     = var.services_dashboard_log_retention_days >= 1 && var.services_dashboard_log_retention_days <= 7
    error_message = "Services dashboard log retention must be between 1 and 7 days for cost optimization."
  }
}

variable "services_dashboard_refresh_interval" {
  description = "Dashboard refresh interval in seconds (minimum 300 for API efficiency)"
  type        = number
  default     = 300

  validation {
    condition     = var.services_dashboard_refresh_interval >= 300
    error_message = "Services dashboard refresh interval must be at least 300 seconds (5 minutes) for API efficiency."
  }
}

variable "services_dashboard_on_demand_optimized" {
  description = "Enable on-demand optimization for portfolio usage patterns (current session focus)"
  type        = bool
  default     = true
}
variable "enable_deployment_dashboard" {
  description = "Enable the Deployment Dashboard for portfolio deployment monitoring (focused on ECS deployments and container startup)"
  type        = bool
  default     = false
}

variable "deployment_dashboard_timeout_minutes" {
  description = "Maximum deployment time in minutes before considering failed"
  type        = number
  default     = 30

  validation {
    condition     = var.deployment_dashboard_timeout_minutes >= 10 && var.deployment_dashboard_timeout_minutes <= 60
    error_message = "Deployment dashboard timeout must be between 10 and 60 minutes."
  }
}

variable "deployment_dashboard_startup_timeout_minutes" {
  description = "Maximum container startup time in minutes for deployment monitoring"
  type        = number
  default     = 10

  validation {
    condition     = var.deployment_dashboard_startup_timeout_minutes >= 5 && var.deployment_dashboard_startup_timeout_minutes <= 30
    error_message = "Deployment dashboard startup timeout must be between 5 and 30 minutes."
  }
}

variable "deployment_dashboard_memory_startup_threshold" {
  description = "Memory utilization threshold during startup (higher than normal operations)"
  type        = number
  default     = 90

  validation {
    condition     = var.deployment_dashboard_memory_startup_threshold >= 70 && var.deployment_dashboard_memory_startup_threshold <= 100
    error_message = "Deployment dashboard memory startup threshold must be between 70 and 100 percent."
  }
}

variable "deployment_dashboard_log_retention_days" {
  description = "Log retention period in days for Deployment Dashboard (optimized for cost: 1-7 days)"
  type        = number
  default     = 3

  validation {
    condition     = var.deployment_dashboard_log_retention_days >= 1 && var.deployment_dashboard_log_retention_days <= 7
    error_message = "Deployment dashboard log retention must be between 1 and 7 days for cost optimization."
  }
}

variable "deployment_dashboard_refresh_interval" {
  description = "Deployment dashboard refresh interval in seconds (minimum 300 for API efficiency)"
  type        = number
  default     = 300

  validation {
    condition     = var.deployment_dashboard_refresh_interval >= 300
    error_message = "Deployment dashboard refresh interval must be at least 300 seconds (5 minutes) for API efficiency."
  }
}

variable "deployment_dashboard_on_demand_optimized" {
  description = "Enable on-demand optimization for portfolio deployment patterns (current session focus)"
  type        = bool
  default     = true
}

variable "deployment_dashboard_enable_alarms" {
  description = "Enable deployment-related alarms (optional for portfolio projects)"
  type        = bool
  default     = false
}
variable "enable_simplified_cloudwatch_queries" {
  description = "Enable simplified CloudWatch Insights queries for portfolio monitoring (replaces complex enhanced dashboard queries)"
  type        = bool
  default     = false
}

variable "simplified_queries_enable_startup_monitoring" {
  description = "Enable container startup monitoring queries in simplified CloudWatch queries"
  type        = bool
  default     = true
}

variable "simplified_queries_enable_error_monitoring" {
  description = "Enable simplified error log monitoring queries"
  type        = bool
  default     = true
}

# DNS configuration moved to separate terraform-dns module

# Extraction automation service-related settings (migrated from extraction repo)
variable "extraction_app_name" {
  description = "Application tag for extraction-related service resources"
  type        = string
  default     = "ph-shoes-scrapper-project"
}

variable "extraction_environment" {
  description = "Environment label for extraction-related service resources"
  type        = string
  default     = "dev"
}

variable "extraction_project_tag" {
  description = "Project tag required on service-related resources"
  type        = string
  default     = "PH-Shoes"
}

variable "extraction_service_name" {
  description = "Service name used for IAM policy naming"
  type        = string
  default     = "ph-shoes-account-service"
}

variable "extraction_env_tag" {
  description = "Environment tag value required by ResourceTag conditions"
  type        = string
  default     = "dev"
}

variable "extraction_extra_tags" {
  description = "Additional tags for extraction-related service resources"
  type        = map(string)
  default     = {}
}

variable "extraction_runtime" {
  description = "Where the service IAM role is assumed: ecs | ec2 | lambda"
  type        = string
  default     = "ecs"
  validation {
    condition     = contains(["ecs", "ec2", "lambda"], var.extraction_runtime)
    error_message = "extraction_runtime must be one of: ecs, ec2, lambda."
  }
}

variable "extraction_allow_table_delete" {
  description = "Allow DeleteTable for extraction-related service IAM role"
  type        = bool
  default     = false
}

variable "extraction_ses_enable_event_destination" {
  description = "Set to true to provision SES configuration set + SNS event destination."
  type        = bool
  default     = false
}

variable "extraction_ses_configuration_set_name" {
  description = "Name of the SES configuration set to create."
  type        = string
  default     = ""
}

variable "extraction_ses_event_destination_name" {
  description = "Name for the SES event destination."
  type        = string
  default     = "sns-event-destination"
}

variable "extraction_ses_sns_topic_name" {
  description = "SNS topic name that receives SES events."
  type        = string
  default     = ""
}

variable "extraction_ses_webhook_endpoint" {
  description = "HTTPS endpoint subscribed to the SNS topic (e.g., user-accounts SES webhook)."
  type        = string
  default     = ""
}

variable "extraction_ses_matching_event_types" {
  description = "SES event types to forward to SNS."
  type        = list(string)
  default     = ["BOUNCE", "COMPLAINT"]
}

variable "extraction_accounts_service_name_prefix" {
  description = "Prefix for naming the user-accounts IAM resources."
  type        = string
  default     = "ph-shoes"
}

variable "extraction_accounts_service_ses_from_address" {
  description = "Verified SES From address used by the user-accounts service."
  type        = string
  default     = "no-reply@ph-shoes.app"
}

variable "extraction_accounts_service_create_access_key" {
  description = "Whether to create an IAM access key for the service user."
  type        = bool
  default     = true
}

variable "extraction_accounts_service_include_env_in_name" {
  description = "Append -<env> to IAM resource names for the accounts service."
  type        = bool
  default     = false
}

variable "extraction_accounts_service_name_override" {
  description = "Hard override for the IAM user name (leave blank for auto naming)."
  type        = string
  default     = ""
}

variable "extraction_migrations_table_name" {
  description = "DynamoDB table that stores schema migration versions"
  type        = string
  default     = "migration_versions"
}

variable "extraction_migration_table_billing_mode" {
  description = "Billing mode for the migration versions table."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "extraction_migration_table_read_capacity" {
  description = "Read capacity (used only when billing mode is PROVISIONED)."
  type        = number
  default     = 1
}

variable "extraction_migration_table_write_capacity" {
  description = "Write capacity (used only when billing mode is PROVISIONED)."
  type        = number
  default     = 1
}

variable "extraction_migration_table_enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery backups for the migration table."
  type        = bool
  default     = true
}

variable "extraction_domain_zone_name" {
  description = "Route 53 hosted zone name (e.g., phshoesproject.com)."
  type        = string
  default     = "phshoesproject.com"
}

variable "extraction_render_www_target" {
  description = "Render frontend hostname for www CNAME."
  type        = string
  default     = "ph-shoes-frontend.onrender.com"
}

variable "extraction_create_root_a" {
  description = "Create apex A record pointing to Render fallback IP."
  type        = bool
  default     = true
}

variable "extraction_root_a_ip" {
  description = "IPv4 address for apex/root A record."
  type        = string
  default     = "216.24.57.1"
}

variable "extraction_additional_cnames" {
  description = "Optional additional CNAMEs for the zone."
  type        = map(string)
  default     = {}
}

variable "extraction_manage_ses" {
  description = "Whether to create SES domain identity + DKIM records."
  type        = bool
  default     = true
}

variable "extraction_ses_domain" {
  description = "Domain to verify with SES (defaults to zone name when empty)."
  type        = string
  default     = ""
}

variable "extraction_create_mail_from" {
  description = "Whether to configure MAIL FROM subdomain."
  type        = bool
  default     = false
}

variable "extraction_mail_from_subdomain" {
  description = "MAIL FROM subdomain (only used when create_mail_from = true)."
  type        = string
  default     = "mail"
}

