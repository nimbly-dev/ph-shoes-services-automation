ecs_instance_type = "t3.micro"

ecs_instance_ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# Cloudflare DNS configuration
use_cloudflare_dns = true
# cloudflare_api_token will be set via environment variable or GitHub secrets
# cloudflare_zone_id will be set via environment variable or GitHub secrets
