output "current_instance_ips" {
  description = "Current EC2 instance public IPs"
  value       = data.aws_instances.ecs_instances.public_ips
}

output "route53_zone_id" {
  description = "Route53 zone ID for the domain"
  value       = data.aws_route53_zone.frontend.zone_id
}

output "dns_provider" {
  description = "DNS provider being used (route53 or cloudflare)"
  value       = var.use_cloudflare_dns ? "cloudflare" : "route53"
}

output "dns_records_created" {
  description = "DNS records that were created"
  value = var.use_cloudflare_dns ? {
    cloudflare_records = concat(
      [for record in cloudflare_record.frontend : "${record.name} -> ${record.content}"],
      [for record in cloudflare_record.subdomains : "${record.name}.${var.domain_name} -> ${record.content}"]
    )
  } : {
    route53_records = concat(
      [for record in aws_route53_record.frontend : "${record.name} -> ${join(", ", record.records)}"],
      [for record in aws_route53_record.subdomains : "${record.name} -> ${join(", ", record.records)}"]
    )
  }
}