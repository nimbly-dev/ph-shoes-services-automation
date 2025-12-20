# Data sources to get current EC2 instance IPs from the ECS cluster
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

# Route 53 A records (only when not using Cloudflare)
resource "aws_route53_record" "frontend" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = length(data.aws_instances.ecs_instances.public_ips) > 0 ? [data.aws_instances.ecs_instances.public_ips[0]] : ["127.0.0.1"]
}

resource "aws_route53_record" "subdomains" {
  for_each = var.use_cloudflare_dns ? toset([]) : toset(var.subdomain_services)
  
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = length(data.aws_instances.ecs_instances.public_ips) > 0 ? [data.aws_instances.ecs_instances.public_ips[0]] : ["127.0.0.1"]
}

# Cloudflare DNS A records (only when using Cloudflare)
resource "cloudflare_record" "frontend" {
  count   = var.use_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  type    = "A"
  content = length(data.aws_instances.ecs_instances.public_ips) > 0 ? data.aws_instances.ecs_instances.public_ips[0] : "127.0.0.1"
  ttl     = 300
}

resource "cloudflare_record" "subdomains" {
  for_each = var.use_cloudflare_dns ? toset(var.subdomain_services) : toset([])
  
  zone_id = var.cloudflare_zone_id
  name    = each.key
  type    = "A"
  content = length(data.aws_instances.ecs_instances.public_ips) > 0 ? data.aws_instances.ecs_instances.public_ips[0] : "127.0.0.1"
  ttl     = 300
}