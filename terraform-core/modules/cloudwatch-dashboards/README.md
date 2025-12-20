# CloudWatch Dashboards Module

This module implements comprehensive Grafana-style CloudWatch dashboards for the PH Shoes microservices migration project. It provides three main dashboards with advanced monitoring capabilities.

## Dashboards Implemented

### 1. System Overview Dashboard (`${cluster_name}-system-overview`)

**Purpose:** Unified view of system health, cost tracking, and deployment events

**Widgets:**
- **Service Health Status:** Real-time running task counts for all services
- **Cost Tracking & Resource Utilization:** Billing metrics and cluster resource usage
- **Current Service CPU Status:** Single-value display of current CPU utilization
- **ECS Cluster Health Overview:** Active services, pending/running tasks, container instances
- **Recent Deployment Events Timeline:** Log-based view of recent RUNNING/STOPPED events

**Requirements Addressed:** 9.1, 9.4, 9.7

### 2. Service Performance Dashboard (`${cluster_name}-service-performance`)

**Purpose:** Detailed performance metrics and business KPI monitoring

**Widgets:**
- **API Response Times:** Time-series graphs for backend service response times
- **API Request Rates:** Request count metrics for all backend services
- **API Error Rates (5XX):** Error tracking for backend services
- **Per-Service Memory Utilization:** Memory usage across all services
- **Per-Service CPU Utilization:** CPU usage across all services
- **Top Errors - Log Insights:** CloudWatch Insights query for error analysis
- **Service Health Check Status:** Health check status indicators

**Requirements Addressed:** 9.2, 9.3, 9.5, 9.6

### 3. Infrastructure Dashboard (`${cluster_name}-infrastructure`)

**Purpose:** Infrastructure health, cost breakdown, and resource monitoring

**Widgets:**
- **EC2 Instance Health:** CPU and Network I/O for Auto Scaling Group
- **ECS Cluster Utilization:** CPU/Memory reservation and utilization
- **Auto Scaling Activity:** ASG capacity and instance states
- **Cost Breakdown by Service:** Billing metrics for ECS, EC2, CloudWatch, ECR
- **Log Group Activity & Size Monitoring:** Log activity across all services

**Requirements Addressed:** 9.2, 9.4, 8.1, 8.2

## CloudWatch Insights Queries

### Pre-built Query Library

1. **Top Errors Query** (`${cluster_name}-top-errors`)
   - Analyzes ERROR messages across all log groups
   - Groups by log stream and time bins
   - Provides 50 most recent error occurrences

2. **Service Response Times** (`${cluster_name}-response-times`)
   - Parses response time metrics from application logs
   - Calculates avg/max/min response times
   - Time-series analysis for performance trends

3. **Cost Analysis** (`${cluster_name}-cost-analysis`)
   - Tracks ECS task lifecycle events
   - Provides hourly cost correlation data
   - Supports cost optimization analysis

**Requirements Addressed:** 9.5, 9.6

## Composite Alarms

### Intelligent Alerting System

1. **System Health Composite Alarm** (`${cluster_name}-system-health`)
   - Combines task count, CPU, and memory alarms for all services
   - Triggers when any service experiences issues
   - Reduces false positives through logical OR combination

2. **Cost Anomaly Composite Alarm** (`${cluster_name}-cost-anomaly`)
   - Combines CPU and memory high utilization alarms
   - Detects unexpected resource usage patterns
   - Supports cost optimization workflows

**Requirements Addressed:** 4.3, 9.7

## Configuration

### Required Variables

```hcl
cluster_name            = "ph-shoes-services-ecs"
service_names           = ["frontend", "user-accounts", "catalog", "alerts", "text-search"]
autoscaling_group_name  = "ph-shoes-ecs-asg"
alarm_actions           = ["arn:aws:sns:region:account:topic"]
```

### Optional Variables

```hcl
enable_cost_tracking   = true    # Enable cost tracking widgets
log_retention_days     = 7       # Log retention period
tags                   = {}      # Resource tags
```

## Outputs

- **Dashboard URLs:** Direct links to each dashboard in AWS Console
- **Dashboard Names:** List of created dashboard names for automation
- **Query Definition Names:** CloudWatch Insights query names
- **Composite Alarm Names:** Intelligent alarm names for monitoring

## Cost Optimization

This module is designed for cost-efficient monitoring:

- **Free Tier Compliance:** Stays within CloudWatch free tier limits (10 dashboards, 50 metrics)
- **Configurable Retention:** Log retention configurable via tfvars (default 7 days)
- **Cost Tracking:** Built-in cost monitoring widgets
- **Efficient Queries:** Optimized CloudWatch Insights queries to minimize API costs

## Usage

```hcl
module "cloudwatch_dashboards" {
  source = "./modules/cloudwatch-dashboards"

  cluster_name            = var.ecs_cluster_name
  service_names           = var.monitored_services
  autoscaling_group_name  = module.ecs_cluster.autoscaling_group_name
  alarm_actions           = [module.cloudwatch_monitoring.sns_topic_arn]
  enable_cost_tracking    = var.enable_cost_tracking
  log_retention_days      = var.log_retention_days
  tags                    = local.common_tags
}
```

## Integration with Existing Infrastructure

This module integrates seamlessly with:
- **ECS Cluster Module:** Uses cluster name and service names
- **CloudWatch Monitoring Module:** References existing alarms and SNS topics
- **Auto Scaling Group:** Monitors ASG metrics and instance health
- **Log Groups:** Queries existing log groups created by services

## Dashboard Access

After deployment, dashboards are accessible via:
1. AWS Console → CloudWatch → Dashboards
2. Direct URLs provided in terraform outputs
3. CloudWatch mobile app for on-the-go monitoring

## Troubleshooting

### Common Issues

1. **Missing Metrics:** Ensure ECS Container Insights is enabled
2. **Empty Widgets:** Verify service names match actual ECS service names
3. **Cost Widgets:** Billing metrics may take 24 hours to appear
4. **Log Queries:** Ensure log groups exist and contain data

### Validation

```bash
# Verify dashboards exist
aws cloudwatch list-dashboards --dashboard-name-prefix ph-shoes-services-ecs

# Test CloudWatch Insights queries
aws logs start-query --log-group-name /backend/user-accounts --start-time 1640995200 --end-time 1640998800 --query-string "fields @timestamp, @message | limit 10"
```