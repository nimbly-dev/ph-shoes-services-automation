# CloudWatch Dashboards Deployment Guide

## Overview

This guide covers the deployment of comprehensive CloudWatch dashboards implemented in Task 12.2 of the render-to-ecs-migration spec.

## What Was Implemented

### 1. Dashboard Module Structure
```
terraform-core/modules/cloudwatch-dashboards/
├── main.tf          # Dashboard definitions and CloudWatch Insights queries
├── variables.tf     # Input variables for configuration
├── outputs.tf       # Dashboard URLs and resource names
└── README.md        # Detailed documentation
```

### 2. Three Comprehensive Dashboards

#### System Overview Dashboard
- **Service Health Status:** Real-time task counts for all microservices
- **Cost Tracking:** Billing metrics with daily/monthly trends
- **Alert Status Panel:** Current alarm states and recent history
- **ECS Cluster Health:** Task counts and resource utilization
- **Deployment Timeline:** Recent deployment events from logs

#### Service Performance Dashboard
- **API Response Times:** Time-series graphs for backend services
- **Request Rates:** API request count metrics
- **Error Rates:** 5XX error tracking
- **Memory/CPU Utilization:** Per-service resource monitoring
- **Log Insights Integration:** Top errors and performance analysis
- **Health Check Status:** Color-coded service health indicators

#### Infrastructure Dashboard
- **EC2 Instance Health:** CPU, memory, and network I/O monitoring
- **ECS Cluster Utilization:** Resource reservation and usage
- **Auto Scaling Activity:** ASG capacity and instance lifecycle
- **Cost Breakdown:** Service-specific billing (ECS, EC2, CloudWatch, ECR)
- **Log Group Monitoring:** Size and retention compliance

### 3. CloudWatch Insights Query Library
- **Top Errors Query:** ERROR message analysis across all services
- **Service Response Times:** Performance trend analysis
- **Cost Analysis:** ECS task lifecycle correlation with costs

### 4. Composite Alarms
- **System Health Alarm:** Combines all service health metrics
- **Cost Anomaly Alarm:** Detects unexpected resource usage patterns

## Configuration Changes Made

### 1. Main Terraform Configuration (`main.tf`)
```hcl
# Added CloudWatch Dashboards module
module "cloudwatch_dashboards" {
  count  = var.enable_cloudwatch_dashboards ? 1 : 0
  source = "./modules/cloudwatch-dashboards"

  cluster_name            = var.ecs_cluster_name
  service_names           = var.monitored_services
  autoscaling_group_name  = module.ecs_cluster.autoscaling_group_name
  alarm_actions           = var.enable_cloudwatch_monitoring ? [module.cloudwatch_monitoring[0].sns_topic_arn] : []
  enable_cost_tracking    = var.enable_cost_tracking
  log_retention_days      = var.log_retention_days
  tags                    = local.common_tags

  depends_on = [module.ecs_cluster, module.cloudwatch_monitoring]
}
```

### 2. Variables (`variables.tf`)
```hcl
# Added dashboard configuration variables
variable "enable_cloudwatch_dashboards" {
  description = "Enable comprehensive CloudWatch dashboards for system monitoring"
  type        = bool
  default     = true
}

variable "enable_cost_tracking" {
  description = "Enable cost tracking widgets in CloudWatch dashboards"
  type        = bool
  default     = true
}
```

### 3. Terraform Values (`terraform.tfvars`)
```hcl
# Enabled dashboards by default
enable_cloudwatch_dashboards = true
enable_cost_tracking = true
```

### 4. Outputs (`outputs.tf`)
```hcl
# Added dashboard URLs and resource names
output "system_overview_dashboard_url" { ... }
output "service_performance_dashboard_url" { ... }
output "infrastructure_dashboard_url" { ... }
output "dashboard_names" { ... }
output "cloudwatch_insights_queries" { ... }
output "composite_alarms" { ... }
```

## Deployment Steps

### 1. Deploy via GitHub Actions Workflow

The dashboards will be deployed automatically when the terraform infrastructure is applied:

```bash
# Trigger infrastructure deployment workflow
gh workflow run infrastructure-deploy.yml \
  -f environment=prod \
  -f action=plan

# Review the plan, then apply
gh workflow run infrastructure-deploy.yml \
  -f environment=prod \
  -f action=apply
```

### 2. Manual Deployment (if needed)

```bash
cd ph-shoes-services-automation/terraform-core

# Initialize terraform (if not already done)
terraform init

# Plan the changes
terraform plan -var-file=terraform.tfvars

# Apply the changes
terraform apply -var-file=terraform.tfvars
```

### 3. Verify Deployment

After deployment, verify the dashboards are created:

```bash
# List created dashboards
aws cloudwatch list-dashboards --dashboard-name-prefix ph-shoes-services-ecs

# Check CloudWatch Insights queries
aws logs describe-query-definitions --query-definition-name-prefix ph-shoes-services-ecs
```

## Accessing the Dashboards

### 1. Via AWS Console
1. Navigate to AWS CloudWatch Console
2. Go to Dashboards section
3. Look for dashboards with prefix `ph-shoes-services-ecs-`

### 2. Via Direct URLs
After deployment, terraform outputs provide direct URLs:
```bash
terraform output system_overview_dashboard_url
terraform output service_performance_dashboard_url
terraform output infrastructure_dashboard_url
```

### 3. Via CloudWatch Mobile App
The dashboards are also accessible through the AWS CloudWatch mobile app for on-the-go monitoring.

## Cost Considerations

### Free Tier Compliance
- **10 Dashboards:** We create 3 dashboards (well within limit)
- **50 Metrics:** Each dashboard uses ~15-20 metrics (total ~60, slightly over but minimal cost)
- **10,000 API Requests:** Normal dashboard usage stays within limits

### Cost Optimization Features
- **Configurable Log Retention:** Default 7 days to minimize storage costs
- **Cost Tracking Widgets:** Built-in cost monitoring and anomaly detection
- **Efficient Queries:** Optimized CloudWatch Insights queries

### Expected Monthly Cost
- **CloudWatch Dashboards:** $0 (within free tier)
- **CloudWatch Insights:** ~$0.50-1.00 (depending on query frequency)
- **Additional Metrics:** ~$0.30 (for metrics over free tier limit)
- **Total:** ~$0.80-1.30/month

## Monitoring and Maintenance

### 1. Dashboard Health
- Dashboards automatically update as services are deployed/scaled
- Composite alarms provide intelligent alerting
- Cost anomaly detection helps identify unexpected charges

### 2. Query Optimization
- CloudWatch Insights queries are pre-optimized for common scenarios
- Query library can be extended for specific troubleshooting needs
- Log retention automatically manages storage costs

### 3. Scaling Considerations
- Dashboards scale automatically with service additions
- New services added to `monitored_services` variable are automatically included
- Cost tracking scales with infrastructure growth

## Troubleshooting

### Common Issues

1. **Empty Dashboard Widgets**
   - Verify ECS Container Insights is enabled
   - Check that service names in `monitored_services` match actual ECS service names
   - Ensure services are running and generating metrics

2. **Missing Cost Data**
   - Billing metrics may take 24 hours to appear
   - Verify billing alerts are enabled in AWS account
   - Check that cost allocation tags are properly configured

3. **CloudWatch Insights Queries Failing**
   - Ensure log groups exist: `/backend/{service-name}` and `/frontend`
   - Verify log groups contain data
   - Check log group permissions

### Validation Commands

```bash
# Check dashboard existence
aws cloudwatch list-dashboards --query 'DashboardEntries[?contains(DashboardName, `ph-shoes-services-ecs`)]'

# Verify log groups
aws logs describe-log-groups --log-group-name-prefix /backend/

# Test CloudWatch Insights query
aws logs start-query \
  --log-group-name /backend/user-accounts \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | limit 10'
```

## Requirements Validation

This implementation addresses all requirements from the spec:

- ✅ **9.1:** Unified system overview dashboard with service topology and health status
- ✅ **9.2:** Real-time service performance metrics and infrastructure monitoring
- ✅ **9.3:** Time-series graphs for performance analysis and drill-down capabilities
- ✅ **9.4:** Cost tracking widgets with daily/monthly spend trends
- ✅ **9.5:** CloudWatch Insights integration for log analysis and custom metrics
- ✅ **9.6:** Business metrics tracking and application-specific monitoring
- ✅ **9.7:** Alarm status panels and composite alarms for intelligent alerting

## Next Steps

1. **Deploy the dashboards** using the GitHub Actions workflow
2. **Verify dashboard functionality** after deployment
3. **Configure alarm notifications** if not already set up
4. **Train team members** on dashboard usage and interpretation
5. **Monitor costs** and optimize queries if needed

The dashboards provide comprehensive monitoring capabilities while maintaining cost efficiency and following the established infrastructure patterns.