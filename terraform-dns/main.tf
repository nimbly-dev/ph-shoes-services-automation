# Data sources to get current EC2 instance IPs and ECS task placement
data "aws_instances" "ecs_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["ph-shoes-services-ecs-asg"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "aws_route53_zone" "frontend" {
  name         = var.domain_name
  private_zone = false
}

# Data source to get running tasks and their placement using external script
data "external" "service_placement" {
  program = ["bash", "${path.module}/get-service-placement.sh"]
}

# Route 53 records with smart service-to-instance routing (only when not using Cloudflare)
resource "aws_route53_record" "frontend" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.frontend_ip]
}

resource "aws_route53_record" "accounts" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "accounts.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.accounts_ip]
}

resource "aws_route53_record" "catalog" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "catalog.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.catalog_ip]
}

resource "aws_route53_record" "alerts" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "alerts.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.alerts_ip]
}

resource "aws_route53_record" "text_search" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "text-search.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.text_search_ip]
}

# Cloudflare DNS records with smart service-to-instance routing
# Root domain A record - points to frontend instance
resource "cloudflare_record" "frontend" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "@"  # @ represents the root domain
  type            = "A"
  content         = data.external.service_placement.result.frontend_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Frontend service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

# Smart subdomain routing - each subdomain points to the instance running that service
resource "cloudflare_record" "accounts" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "accounts"
  type            = "A"
  content         = data.external.service_placement.result.accounts_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "User accounts service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

resource "cloudflare_record" "catalog" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "catalog"
  type            = "A"
  content         = data.external.service_placement.result.catalog_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Catalog service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

resource "cloudflare_record" "alerts" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "alerts"
  type            = "A"
  content         = data.external.service_placement.result.alerts_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Alerts service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

resource "cloudflare_record" "text_search" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "text-search"
  type            = "A"
  content         = data.external.service_placement.result.text_search_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Text search service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}