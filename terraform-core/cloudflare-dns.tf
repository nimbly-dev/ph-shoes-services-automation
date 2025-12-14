# Cloudflare DNS records (alternative to Route53)
# These will be used when var.use_cloudflare_dns is true

# Get EC2 instance IP for DNS records
locals {
  instance_ip = length(data.aws_instances.ecs_instances.public_ips) > 0 ? data.aws_instances.ecs_instances.public_ips[0] : "127.0.0.1"
}

# Main domain record
resource "cloudflare_record" "frontend" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "phshoesproject.com"
  value   = local.instance_ip
  type    = "A"
  ttl     = 300
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Frontend SPA - managed by Terraform"
}

# Subdomain records
resource "cloudflare_record" "catalog" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "catalog"
  value   = local.instance_ip
  type    = "A"
  ttl     = 300
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Catalog service - managed by Terraform"
}

resource "cloudflare_record" "text_search" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "text-search"
  value   = local.instance_ip
  type    = "A"
  ttl     = 300
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Text search service - managed by Terraform"
}

resource "cloudflare_record" "accounts" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "accounts"
  value   = local.instance_ip
  type    = "A"
  ttl     = 300
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "User accounts service - managed by Terraform"
}

resource "cloudflare_record" "alerts" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "alerts"
  value   = local.instance_ip
  type    = "A"
  ttl     = 300
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Alerts service - managed by Terraform"
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