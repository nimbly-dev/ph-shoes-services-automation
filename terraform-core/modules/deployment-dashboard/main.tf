
locals {
  # Service log groups
  services = {
    frontend      = { log_group = "/ecs/ph-shoes-services-automation-frontend", display_name = "Frontend SPA", port = 80 }
    user-accounts = { log_group = "/ecs/ph-shoes-services-automation-user-accounts", display_name = "User Accounts Service", port = 8082 }
    catalog       = { log_group = "/ecs/ph-shoes-services-automation-catalog", display_name = "Catalog Service", port = 8083 }
    alerts        = { log_group = "/ecs/ph-shoes-services-automation-alerts", display_name = "Alerts Service", port = 8084 }
    text-search   = { log_group = "/ecs/ph-shoes-services-automation-text-search", display_name = "Text Search Service", port = 8085 }
  }

  # Deployment thresholds
  deployment_config = {
    deployment_timeout_minutes = 30
    startup_timeout_minutes    = 10
    memory_startup_threshold   = 90
  }
  dashboard_properties = {
    region           = data.aws_region.current.name
    refresh_interval = var.dashboard_refresh_interval
    period           = 300
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "deployment_dashboard" {
  dashboard_name = "${var.cluster_name}-deployment-status"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: Current Deployment Status for active deployments
      {
        type   = "log"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          query  = "SOURCE '/aws/ecs/containerinsights/${var.cluster_name}/performance' | fields @timestamp, @message, @logStream | filter @message like /deployment/ or @message like /task/ or @message like /service/ | filter @timestamp > date_sub(now(), interval 1 hour) | sort @timestamp desc | limit 20"
          region = local.dashboard_properties.region
          title  = "Current Deployment Status (Last Hour)"
          view   = "table"
        }
      },

      # Widget 2: Last Deployment Results (success/failure status)
      {
        type   = "text"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          markdown = <<-EOT
# Last Deployment Results

## Deployment Status Overview
Check ECS console for detailed deployment status:
- **[ECS Services Console](https://${local.dashboard_properties.region}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name}/services)**
- **[ECS Tasks Console](https://${local.dashboard_properties.region}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name}/tasks)**

## Quick Deployment Checks
✅ **Success Indicators:**
- All services show "RUNNING" status
- Task count matches desired count
- No recent task failures

❌ **Failure Indicators:**
- Services stuck in "PENDING" state
- Task failures in last 30 minutes
- Memory/CPU resource issues

## Portfolio Demo Readiness
- All 5 services deployed and running
- No deployment errors in last hour
- Container startup completed successfully
EOT
          region   = local.dashboard_properties.region
        }
      },

      # Widget 3: Container Startup Logs (current session)
      {
        type   = "log"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          query  = "SOURCE '${join("' | SOURCE '", [for s in local.services : s.log_group])}' | fields @timestamp, @message, @logStream | filter @message like /Starting/ or @message like /Started/ or @message like /Initializing/ or @message like /Ready/ | filter @timestamp > date_sub(now(), interval 30 minute) | sort @timestamp desc | limit 15"
          region = local.dashboard_properties.region
          title  = "Container Startup Logs (Last 30 Min)"
          view   = "table"
        }
      },

      # Widget 4: Memory During Startup (container initialization)
      # Monitor memory usage during container startup phase
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name],
            ["AWS/EC2", "MemoryUtilization", "InstanceType", "t3.micro"]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "Memory During Startup (Current Session - Last Hour)"
          period = local.dashboard_properties.period
          stat   = "Average"
          start  = "-PT1H" # Last 1 hour only
          end    = "PT0H"  # Current time
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "Startup Threshold (${local.deployment_config.memory_startup_threshold}%)"
                value = local.deployment_config.memory_startup_threshold
                color = "#ff7f0e"
              }
            ]
          }
        }
      },
      {
        type   = "text"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          markdown = <<-EOT
# Deployment Quick Links

## ECS Service Management
%{for service_key, service in local.services}
- **[${service.display_name} Service](https://${local.dashboard_properties.region}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name}/services/${service_key}/health)**
%{endfor}

## Deployment Monitoring
- **[Cluster Overview](https://${local.dashboard_properties.region}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name})**
- **[Task Definitions](https://${local.dashboard_properties.region}.console.aws.amazon.com/ecs/v2/task-definitions)**
- **[Service Events](https://${local.dashboard_properties.region}.console.aws.amazon.com/ecs/v2/clusters/${var.cluster_name}/services)**

## Container Logs (Deployment Focus)
%{for service_key, service in local.services}
- **[${service.display_name} Logs](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:log-groups/log-group/${replace(service.log_group, "/", "$252F")})**
%{endfor}

*Direct links to deployment-related resources*
EOT
          region   = local.dashboard_properties.region
        }
      },
      {
        type   = "text"
        x      = 16
        y      = 6
        width  = 8
        height = 6
        properties = {
          markdown = <<-EOT

## System Readiness Checklist

### 🚀 Deployment Status
- [ ] All 5 services deployed
- [ ] No failed deployments in last hour
- [ ] All containers started successfully
- [ ] Memory usage stable during startup

### 📊 Service Health
- [ ] Frontend SPA accessible (Port 80)
- [ ] User Accounts API responding (Port 8082)
- [ ] Catalog API responding (Port 8083)
- [ ] Alerts API responding (Port 8084)
- [ ] Text Search API responding (Port 8085)

### 🔍 Quick Validation
1. Check ECS services are "RUNNING"
2. Verify no recent deployment errors
3. Confirm container startup logs show "Ready"
4. Validate memory usage < 90% during startup

### 🎯 Demo Ready Indicators
✅ **Green**: All services running, no errors
🟡 **Yellow**: Services starting, monitor progress  
🔴 **Red**: Deployment issues, check logs

**Status**: Check ECS console for current state
EOT
          region   = local.dashboard_properties.region
        }
      }
    ]
  })
}

# resource "aws_cloudwatch_query_definition" "ecs_deployment_events" {
#   name = "${var.cluster_name}-ecs-deployment-events"
#   log_group_names = ["/aws/ecs/containerinsights/${var.cluster_name}/performance"]
#   query_string = <<EOF
# fields @timestamp, @message, @logStream
# | filter @timestamp > date_sub(now(), interval 1 hour)
# | sort @timestamp desc
# | limit 30
# EOF
# }

# resource "aws_cloudwatch_query_definition" "container_startup_logs" {
#   name = "${var.cluster_name}-container-startup-logs"
#   log_group_names = [for service in local.services : service.log_group]
#   query_string = <<EOF
# fields @timestamp, @message, @logStream
# | filter @message like /Starting/ or @message like /Started/ or @message like /Initializing/ or @message like /Ready/ or @message like /Listening/
# | filter @timestamp > date_sub(now(), interval 30 minute)
# | sort @timestamp desc
# | limit 20
# EOF
# }

resource "aws_cloudwatch_query_definition" "deployment_troubleshooting" {
  name = "${var.cluster_name}-deployment-troubleshooting"

  log_group_names = concat(
    ["/aws/ecs/containerinsights/${var.cluster_name}/performance"],
    [for service in local.services : service.log_group]
  )

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /ERROR/ or @message like /FATAL/ or @message like /Exception/ or @message like /failed/ or @message like /timeout/
| filter @timestamp > date_sub(now(), interval 30 minute)
| sort @timestamp desc
| limit 15
EOF
}



