ecs_instance_type = "t3.micro"

# t3.micro can support 2 containers per instance
# Scale to 3 instances to support all 5 services (frontend + 4 backends)
ecs_desired_capacity = 3
ecs_min_size         = 1
ecs_max_size         = 3

# Standardized application naming
ecs_cluster_name = "ph-shoes-services-ecs"

# Memory allocation optimized for t3.micro constraints
frontend_memory_mb = 128
backend_memory_mb  = 456

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
  },
  # Backend service health endpoint ports (8082-8085)
  # These ports are open for AWS ECS health checks and GitHub Actions deployment validation
  # Nginx configuration restricts access to health endpoints only
  {
    from_port   = 8082
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# Cloudflare DNS configuration - moved to separate terraform-dns module
# use_cloudflare_dns = true
# cloudflare_api_token will be set via environment variable or GitHub secrets
# cloudflare_zone_id will be set via environment variable or GitHub secrets

# CloudWatch Monitoring configuration
enable_cloudwatch_monitoring = true
cloudwatch_cpu_threshold     = 80
cloudwatch_memory_threshold  = 80
# cloudwatch_alarm_email can be set via environment variable for notifications

# CloudWatch Dashboards configuration (Task 12.2)
enable_cloudwatch_dashboards = true
enable_cost_tracking         = true
