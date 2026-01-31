ecs_instance_type = "t3.micro"
ecs_desired_capacity = 3
ecs_min_size         = 1
ecs_max_size         = 5
ecs_cluster_name = "ph-shoes-services-ecs"

frontend_memory_mb = 128
backend_memory_mb  = 400

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
  # Backend service health ports
  {
    from_port   = 8082
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# Cloudflare DNS (terraform-dns module)
# use_cloudflare_dns = true
# cloudflare_api_token will be set via environment variable or GitHub secrets
# cloudflare_zone_id will be set via environment variable or GitHub secrets

# CloudWatch monitoring
enable_cloudwatch_monitoring = true
cloudwatch_cpu_threshold     = 80
cloudwatch_memory_threshold  = 80
# cloudwatch_alarm_email can be set via environment variable for notifications

# CloudWatch dashboards (legacy)
enable_cloudwatch_dashboards = false
enable_cost_tracking         = true

# Enhanced CloudWatch dashboard (legacy)
enable_enhanced_cloudwatch_dashboard = false

enable_services_dashboard   = true
enable_deployment_dashboard = true

# Services dashboard thresholds
services_dashboard_memory_normal_threshold   = 70
services_dashboard_memory_warning_threshold  = 80
services_dashboard_memory_critical_threshold = 95

# Deployment dashboard settings
deployment_dashboard_timeout_minutes          = 30
deployment_dashboard_startup_timeout_minutes  = 10
deployment_dashboard_memory_startup_threshold = 90
deployment_dashboard_enable_alarms            = false

# Log retention
log_retention_days                    = 3
enhanced_dashboard_log_retention_days = 3

# Simplified CloudWatch queries
enable_simplified_cloudwatch_queries         = true
simplified_queries_enable_startup_monitoring = true
simplified_queries_enable_error_monitoring   = true
services_dashboard_log_retention_days        = 3
deployment_dashboard_log_retention_days      = 3

# Dashboard refresh intervals
enhanced_dashboard_refresh_interval   = 300
services_dashboard_refresh_interval   = 300
deployment_dashboard_refresh_interval = 300

# On-demand optimization
services_dashboard_on_demand_optimized   = true
deployment_dashboard_on_demand_optimized = true

# Additional ECR Public repositories
additional_ecr_repositories = [
  {
    name        = "ph-shoes-alerts-scheduler-web"
    description = "Spring Boot web module image for alerts scheduler"
  }
]
