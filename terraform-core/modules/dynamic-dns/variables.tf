variable "cluster_name" {
  description = "ECS cluster name to query for service locations"
  type        = string
}

variable "aws_region" {
  description = "AWS region where ECS cluster is deployed"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for DNS records"
  type        = string
}

variable "fallback_ip" {
  description = "Fallback IP address when service is not found"
  type        = string
  default     = "127.0.0.1"
}

variable "services" {
  description = "Map of services to create DNS records for"
  type = map(object({
    service_name = string
    domain       = string
    description  = string
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
