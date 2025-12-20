# Cloudflare DNS records with dynamic service-aware routing
# Uses the dynamic-dns module for service discovery and routing

# Get all EC2 instance IPs for fallback with proper handling for scaled-to-zero scenario
locals {
  instance_ips = data.aws_instances.ecs_instances.public_ips
  # When scaled to zero, use a maintenance page IP or parking page
  # This prevents DNS resolution failures when all instances are terminated
  fallback_ip = length(local.instance_ips) > 0 ? local.instance_ips[0] : "192.0.2.1" # RFC 5737 documentation IP
}

# Dynamic DNS module for deployed services
module "dynamic_dns" {
  source = "./modules/dynamic-dns"
  count  = var.use_cloudflare_dns ? 1 : 0

  cluster_name       = "ph-shoes-services-ecs"
  aws_region         = "ap-southeast-1"
  cloudflare_zone_id = var.cloudflare_zone_id
  fallback_ip        = local.fallback_ip

  services = {
    frontend = {
      service_name = "ph-shoes-services-automation-frontend"
      domain       = "phshoesproject.com"
      description  = "Frontend SPA"
    }
    catalog = {
      service_name = "ph-shoes-services-automation-catalog"
      domain       = "catalog"
      description  = "Catalog service"
    }
    alerts = {
      service_name = "ph-shoes-services-automation-alerts"
      domain       = "alerts"
      description  = "Alerts service"
    }
    user_accounts = {
      service_name = "ph-shoes-services-automation-user-accounts"
      domain       = "accounts"
      description  = "User accounts service"
    }
  }

  tags = local.common_tags
}

# Static DNS records for services not yet deployed
resource "cloudflare_record" "text_search" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "text-search"
  content = local.fallback_ip
  type    = "A"
  ttl     = 1
  proxied = true
  comment = "Text search service - Fallback routing (service not yet deployed)"
}

# Output the DNS records for verification
output "cloudflare_dns_records" {
  value = var.use_cloudflare_dns ? merge(
    module.dynamic_dns[0].dns_records,
    {
      text_search = {
        hostname = cloudflare_record.text_search[0].hostname
        ip       = cloudflare_record.text_search[0].content
        domain   = cloudflare_record.text_search[0].name
      }
    }
  ) : {}
  description = "Cloudflare DNS records created with dynamic service routing"
}

output "service_instance_ips" {
  value       = var.use_cloudflare_dns ? module.dynamic_dns[0].service_ips : {}
  description = "Discovered IP addresses for each service"
}

output "service_discovery_debug" {
  value       = var.use_cloudflare_dns ? module.dynamic_dns[0].service_discovery_details : {}
  description = "Detailed service discovery information including task ARNs, container instances, and EC2 IPs"
}

output "service_routing_summary" {
  value       = var.use_cloudflare_dns ? module.dynamic_dns[0].service_to_ip_mapping : {}
  description = "Summary of service-to-IP mappings for DNS routing validation"
}
