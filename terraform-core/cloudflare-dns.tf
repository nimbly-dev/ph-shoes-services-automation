# Cloudflare DNS records (alternative to Route53)
# These will be used when var.use_cloudflare_dns is true

# Get all EC2 instance IPs for DNS records
locals {
  instance_ips = length(data.aws_instances.ecs_instances.public_ips) > 0 ? data.aws_instances.ecs_instances.public_ips : ["127.0.0.1"]
}

# Main domain records - Route to first instance (where frontend is currently running)
resource "cloudflare_record" "frontend" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "phshoesproject.com"
  content = length(local.instance_ips) > 0 ? local.instance_ips[0] : "127.0.0.1"
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Frontend SPA - Routes to first instance (18.141.24.231)"
}

# Catalog service - Route to second instance (where catalog is currently running)
resource "cloudflare_record" "catalog" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "catalog"
  content = length(local.instance_ips) > 1 ? local.instance_ips[1] : (length(local.instance_ips) > 0 ? local.instance_ips[0] : "127.0.0.1")
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Catalog service - Routes to second instance (54.255.224.125)"
}

# Text Search service dynamic routing (fallback to first instance if not deployed)
resource "cloudflare_record" "text_search" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "text-search"
  content = length(local.instance_ips) > 0 ? local.instance_ips[0] : "127.0.0.1"
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Text search service - Fallback routing (service not yet deployed)"
}

# User Accounts service dynamic routing (fallback to first instance if not deployed)
resource "cloudflare_record" "accounts" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "accounts"
  content = length(local.instance_ips) > 0 ? local.instance_ips[0] : "127.0.0.1"
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "User accounts service - Fallback routing (service not yet deployed)"
}

# Alerts service - Route to second instance (where alerts is currently running)
resource "cloudflare_record" "alerts" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "alerts"
  content = length(local.instance_ips) > 1 ? local.instance_ips[1] : (length(local.instance_ips) > 0 ? local.instance_ips[0] : "127.0.0.1")
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Alerts service - Routes to second instance (54.255.224.125)"
}

# Output the DNS records for verification
output "cloudflare_dns_records" {
  value = var.use_cloudflare_dns ? {
    frontend    = cloudflare_record.frontend[0].hostname
    catalog     = cloudflare_record.catalog[0].hostname
    text_search = cloudflare_record.text_search[0].hostname
    accounts    = cloudflare_record.accounts[0].hostname
    alerts      = cloudflare_record.alerts[0].hostname
  } : {}
  description = "Cloudflare DNS records created"
}