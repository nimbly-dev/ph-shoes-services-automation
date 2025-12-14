# Cloudflare DNS records (alternative to Route53)
# These will be used when var.use_cloudflare_dns is true

# Get all EC2 instance IPs for DNS records
locals {
  instance_ips = length(data.aws_instances.ecs_instances.public_ips) > 0 ? data.aws_instances.ecs_instances.public_ips : ["127.0.0.1"]
}

# Main domain records (one per instance for load distribution)
resource "cloudflare_record" "frontend" {
  count   = var.use_cloudflare_dns ? length(local.instance_ips) : 0
  zone_id = var.cloudflare_zone_id
  name    = "phshoesproject.com"
  content = local.instance_ips[count.index]
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Frontend SPA - Instance ${count.index + 1} - managed by Terraform"
}

# Subdomain records (one per instance for load distribution)
resource "cloudflare_record" "catalog" {
  count   = var.use_cloudflare_dns ? length(local.instance_ips) : 0
  zone_id = var.cloudflare_zone_id
  name    = "catalog"
  content = local.instance_ips[count.index]
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Catalog service - Instance ${count.index + 1} - managed by Terraform"
}

resource "cloudflare_record" "text_search" {
  count   = var.use_cloudflare_dns ? length(local.instance_ips) : 0
  zone_id = var.cloudflare_zone_id
  name    = "text-search"
  content = local.instance_ips[count.index]
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Text search service - Instance ${count.index + 1} - managed by Terraform"
}

resource "cloudflare_record" "accounts" {
  count   = var.use_cloudflare_dns ? length(local.instance_ips) : 0
  zone_id = var.cloudflare_zone_id
  name    = "accounts"
  content = local.instance_ips[count.index]
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "User accounts service - Instance ${count.index + 1} - managed by Terraform"
}

resource "cloudflare_record" "alerts" {
  count   = var.use_cloudflare_dns ? length(local.instance_ips) : 0
  zone_id = var.cloudflare_zone_id
  name    = "alerts"
  content = local.instance_ips[count.index]
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Alerts service - Instance ${count.index + 1} - managed by Terraform"
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