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

output "service_placement" {
  description = "Current ECS service placement across instances"
  value = {
    frontend_instance    = data.external.service_placement.result.frontend_ip
    accounts_instance    = data.external.service_placement.result.accounts_ip
    catalog_instance     = data.external.service_placement.result.catalog_ip
    alerts_instance      = data.external.service_placement.result.alerts_ip
    text_search_instance = data.external.service_placement.result.text_search_ip
  }
}

output "dns_records_created" {
  description = "DNS records created with smart service routing"
  value = var.use_cloudflare_dns ? {
    cloudflare_records = [
      "phshoesproject.com -> ${data.external.service_placement.result.frontend_ip} (frontend)",
      "accounts.phshoesproject.com -> ${data.external.service_placement.result.accounts_ip} (user-accounts)",
      "catalog.phshoesproject.com -> ${data.external.service_placement.result.catalog_ip} (catalog)",
      "alerts.phshoesproject.com -> ${data.external.service_placement.result.alerts_ip} (alerts)",
      "text-search.phshoesproject.com -> ${data.external.service_placement.result.text_search_ip} (text-search)"
    ]
  } : {
    route53_records = [
      "phshoesproject.com -> ${data.external.service_placement.result.frontend_ip} (frontend)",
      "accounts.phshoesproject.com -> ${data.external.service_placement.result.accounts_ip} (user-accounts)",
      "catalog.phshoesproject.com -> ${data.external.service_placement.result.catalog_ip} (catalog)",
      "alerts.phshoesproject.com -> ${data.external.service_placement.result.alerts_ip} (alerts)",
      "text-search.phshoesproject.com -> ${data.external.service_placement.result.text_search_ip} (text-search)"
    ]
  }
}