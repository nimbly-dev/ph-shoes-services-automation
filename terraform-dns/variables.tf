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

variable "project_name" {
  description = "Project tag used across the stack"
  type        = string
  default     = "ph-shoes-services"
}

variable "owner" {
  description = "Primary owner for tagging"
  type        = string
  default     = "nimbly"
}

# Cloudflare DNS Configuration
variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS management"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for phshoesproject.com"
  type        = string
  sensitive   = true
  default     = ""
}

variable "use_cloudflare_dns" {
  description = "Whether to manage DNS records via Cloudflare (true) or Route53 (false)"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "phshoesproject.com"
}

variable "subdomain_services" {
  description = "List of subdomain services to create DNS records for"
  type        = list(string)
  default     = ["catalog", "accounts", "alerts", "text-search"]
}