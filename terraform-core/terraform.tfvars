ecs_instance_type = "t3.micro"

# Start with 1 instance, can scale up to 3 as needed
ecs_desired_capacity = 1
ecs_min_size = 1
ecs_max_size = 3

# Reduce memory allocation to fit on t3.micro (1GB RAM)
frontend_memory_mb = 128
backend_memory_mb = 200

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
