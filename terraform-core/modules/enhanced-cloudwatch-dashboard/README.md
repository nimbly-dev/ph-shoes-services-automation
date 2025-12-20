# Enhanced CloudWatch Dashboard Module

Comprehensive observability platform for PH Shoes services with AWS free tier optimization.

## Features

- **Error Tracking Panel**: Real-time error monitoring with drill-down links
- **One-Click Log Access**: Direct links to service-specific logs and filters
- **Health Monitoring**: Metrics-log correlation and anomaly detection
- **Security Events**: Authentication failures and API security monitoring
- **ECS Deployment**: Task lifecycle and deployment timeline tracking

## Configuration

### Basic Setup
```hcl
module "enhanced_cloudwatch_dashboard" {
  source = "./modules/enhanced-cloudwatch-dashboard"
  
  cluster_name           = "ph-shoes-services-ecs"
  autoscaling_group_name = "ph-shoes-services-ecs-asg"
  
  # Free tier optimization
  log_retention_days = 3
  max_widget_count   = 32
}
```

### Free Tier Settings
```hcl
# Recommended free tier configuration
enhanced_dashboard_log_retention_days = 3     # 1-7 days
enhanced_dashboard_refresh_interval   = 300   # 5 minutes minimum
enhanced_dashboard_max_widgets        = 32    # Max 50 for free tier
enhanced_dashboard_api_budget         = 2900  # Monthly API requests
```

### Feature Toggles
```hcl
enable_enhanced_free_tier_monitoring = true
enable_enhanced_security_monitoring  = true
enable_enhanced_ecs_monitoring       = true
enable_enhanced_query_optimization   = true
```

## Dashboard Panels

1. **Error Tracking** (8 widgets): Error rates, severity ranking, performance impact
2. **Log Access** (6 widgets): Service logs, filters, time ranges, search templates
3. **Health Monitoring** (6 widgets): System metrics, anomaly detection, resource correlation
4. **Security Events** (4 widgets): Authentication failures, API security metrics
5. **ECS Deployment** (8 widgets): Task lifecycle, deployment timeline, scaling activity

## Free Tier Compliance

- **Dashboards**: 4/10 (40% used)
- **Metrics**: 32/50 (64% used)
- **API Requests**: ~2900/month (29% used)
- **Log Retention**: 3 days (cost optimized)

## Outputs

- `enhanced_dashboard_url`: Direct link to dashboard
- `enhanced_insights_query_urls`: Pre-configured log analysis queries
- `enhanced_free_tier_usage`: Current usage statistics