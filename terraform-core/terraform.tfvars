ecs_instance_type = "t3.micro"

# t3.micro can support 2 containers per instance
# Scale to 3 instances to support all 5 services (frontend + 4 backends)
ecs_desired_capacity = 3
ecs_min_size = 1
ecs_max_size = 3

# Memory allocation optimized for t3.micro constraints
frontend_memory_mb = 128
backend_memory_mb = 456

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
