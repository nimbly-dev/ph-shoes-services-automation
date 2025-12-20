# DNS Configuration
domain_name = "phshoesproject.com"
subdomain_services = ["catalog", "accounts", "alerts", "text-search"]

# DNS Configuration - Use Route53 to match original working setup
use_cloudflare_dns = false  # Switch back to Route53 like original terraform-core
# cloudflare_api_token will be set via environment variable or GitHub secrets
# cloudflare_zone_id will be set via environment variable or GitHub secrets

# Project configuration
project_name = "ph-shoes-services"
environment = "prod"
owner = "nimbly-dev"
aws_region = "ap-southeast-1"