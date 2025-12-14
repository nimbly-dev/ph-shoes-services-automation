# Cloudflare DNS records (alternative to Route53)
# These will be used when var.use_cloudflare_dns is true

# Get all EC2 instance IPs for DNS records
locals {
  instance_ips = length(data.aws_instances.ecs_instances.public_ips) > 0 ? data.aws_instances.ecs_instances.public_ips : ["127.0.0.1"]
}

# Main domain records (dynamic routing based on service distribution)
# Query ECS to find which instance is running the frontend service
data "aws_ecs_service" "frontend" {
  service_name = "ph-shoes-services-automation-frontend"
  cluster_name = "ph-shoes-services-ecs"
}

data "aws_ecs_tasks" "frontend_tasks" {
  cluster = "ph-shoes-services-ecs"
  service = data.aws_ecs_service.frontend.service_name
}

data "aws_ecs_task" "frontend_task" {
  count   = length(data.aws_ecs_tasks.frontend_tasks.task_arns)
  cluster = "ph-shoes-services-ecs"
  task    = data.aws_ecs_tasks.frontend_tasks.task_arns[count.index]
}

# Get container instance for frontend task
data "aws_ecs_container_instance" "frontend_instance" {
  count              = length(data.aws_ecs_task.frontend_task)
  cluster            = "ph-shoes-services-ecs"
  container_instance = data.aws_ecs_task.frontend_task[count.index].container_instance_arn
}

# Get EC2 instance running frontend
data "aws_instance" "frontend_ec2" {
  count       = length(data.aws_ecs_container_instance.frontend_instance)
  instance_id = data.aws_ecs_container_instance.frontend_instance[count.index].ec2_instance_id
}

resource "cloudflare_record" "frontend" {
  count   = var.use_cloudflare_dns && length(data.aws_instance.frontend_ec2) > 0 ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "phshoesproject.com"
  content = data.aws_instance.frontend_ec2[0].public_ip
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Frontend SPA - Dynamic routing to instance running frontend service"
}

# Catalog service dynamic routing
data "aws_ecs_service" "catalog" {
  service_name = "ph-shoes-services-automation-catalog"
  cluster_name = "ph-shoes-services-ecs"
}

data "aws_ecs_tasks" "catalog_tasks" {
  cluster = "ph-shoes-services-ecs"
  service = data.aws_ecs_service.catalog.service_name
}

data "aws_ecs_task" "catalog_task" {
  count   = length(data.aws_ecs_tasks.catalog_tasks.task_arns)
  cluster = "ph-shoes-services-ecs"
  task    = data.aws_ecs_tasks.catalog_tasks.task_arns[count.index]
}

data "aws_ecs_container_instance" "catalog_instance" {
  count              = length(data.aws_ecs_task.catalog_task)
  cluster            = "ph-shoes-services-ecs"
  container_instance = data.aws_ecs_task.catalog_task[count.index].container_instance_arn
}

data "aws_instance" "catalog_ec2" {
  count       = length(data.aws_ecs_container_instance.catalog_instance)
  instance_id = data.aws_ecs_container_instance.catalog_instance[count.index].ec2_instance_id
}

resource "cloudflare_record" "catalog" {
  count   = var.use_cloudflare_dns && length(data.aws_instance.catalog_ec2) > 0 ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "catalog"
  content = data.aws_instance.catalog_ec2[0].public_ip
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Catalog service - Dynamic routing to instance running catalog service"
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

# Alerts service dynamic routing
data "aws_ecs_service" "alerts" {
  service_name = "ph-shoes-services-automation-alerts"
  cluster_name = "ph-shoes-services-ecs"
}

data "aws_ecs_tasks" "alerts_tasks" {
  cluster = "ph-shoes-services-ecs"
  service = data.aws_ecs_service.alerts.service_name
}

data "aws_ecs_task" "alerts_task" {
  count   = length(data.aws_ecs_tasks.alerts_tasks.task_arns)
  cluster = "ph-shoes-services-ecs"
  task    = data.aws_ecs_tasks.alerts_tasks.task_arns[count.index]
}

data "aws_ecs_container_instance" "alerts_instance" {
  count              = length(data.aws_ecs_task.alerts_task)
  cluster            = "ph-shoes-services-ecs"
  container_instance = data.aws_ecs_task.alerts_task[count.index].container_instance_arn
}

data "aws_instance" "alerts_ec2" {
  count       = length(data.aws_ecs_container_instance.alerts_instance)
  instance_id = data.aws_ecs_container_instance.alerts_instance[count.index].ec2_instance_id
}

resource "cloudflare_record" "alerts" {
  count   = var.use_cloudflare_dns && length(data.aws_instance.alerts_ec2) > 0 ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "alerts"
  content = data.aws_instance.alerts_ec2[0].public_ip
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "Alerts service - Dynamic routing to instance running alerts service"
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