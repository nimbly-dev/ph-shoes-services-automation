
locals {
  # Service log groups
  services = {
    frontend      = { log_group = "/ecs/ph-shoes-services-automation-frontend", display_name = "Frontend SPA", port = 80 }
    user-accounts = { log_group = "/ecs/ph-shoes-services-automation-user-accounts", display_name = "User Accounts Service", port = 8082 }
    catalog       = { log_group = "/ecs/ph-shoes-services-automation-catalog", display_name = "Catalog Service", port = 8083 }
    alerts        = { log_group = "/ecs/ph-shoes-services-automation-alerts", display_name = "Alerts Service", port = 8084 }
    text-search   = { log_group = "/ecs/ph-shoes-services-automation-text-search", display_name = "Text Search Service", port = 8085 }
  }

  # Memory thresholds
  memory_thresholds = {
    normal   = 70
    warning  = 80
    critical = 95
  }
  dashboard_properties = {
    region           = data.aws_region.current.name
    refresh_interval = var.dashboard_refresh_interval
    period          = 300
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "services_dashboard" {
  dashboard_name = "${var.cluster_name}-services-status"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: Current Memory Usage for t3.micro instances
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "MemoryUtilization", "InstanceType", "t3.micro"],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "Current Memory Usage (t3.micro) - Last 2 Hours"
          period = local.dashboard_properties.period
          stat   = "Average"
          start  = "-PT2H"  # Last 2 hours only
          end    = "PT0H"   # Current time
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "Normal (${local.memory_thresholds.normal}%)"
                value = local.memory_thresholds.normal
                color = "#2ca02c"
              },
              {
                label = "Warning (${local.memory_thresholds.warning}%)"
                value = local.memory_thresholds.warning
                color = "#ff7f0e"
              },
              {
                label = "Critical (${local.memory_thresholds.critical}%)"
                value = local.memory_thresholds.critical
                color = "#d62728"
              }
            ]
          }
        }
      },
      
      # Widget 2: Memory Status Indicator with visual feedback
      {
        type   = "text"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          markdown = <<-EOT
# Memory Status Indicator

## Current Status
- 🟢 **Normal**: < ${local.memory_thresholds.normal}% (Healthy)
- 🟡 **Warning**: ${local.memory_thresholds.warning}-${local.memory_thresholds.critical}% (Monitor)
- 🔴 **Critical**: > ${local.memory_thresholds.critical}% (Action Needed)

## Quick Actions
- Check container logs for memory leaks
- Review ECS task definitions for memory limits
- Consider container restart if critical

## Memory Optimization Tips
- t3.micro has ~1GB RAM available
- Each service should use <200MB typically
- Monitor for gradual memory increases
EOT
          region = local.dashboard_properties.region
        }
      },

      # Widget 3: Container Log Access with direct CloudWatch links
      {
        type   = "text"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          markdown = <<-EOT
# Container Log Access

## Service Logs (One-Click Access)
%{for service_key, service in local.services}
- **[${service.display_name}](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logsV2:log-groups/log-group/${replace(service.log_group, "/", "$252F")})** (Port ${service.port})
%{endfor}

## Quick Log Queries
- **[All Recent Logs](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logs-insights:queryDetail=~(end~0~start~-7200~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*2c*20*40logStream*0a*7c*20sort*20*40timestamp*20desc*0a*7c*20limit*20100~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))**
- **[Error Logs Only](https://${local.dashboard_properties.region}.console.aws.amazon.com/cloudwatch/home?region=${local.dashboard_properties.region}#logs-insights:queryDetail=~(end~0~start~-7200~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40message*20like*20*2fERROR*2f*0a*7c*20sort*20*40timestamp*20desc*0a*7c*20limit*2050~isLiveTail~false~source~(~'*2fbackend*2fuser-accounts~'*2fbackend*2fcatalog~'*2fbackend*2falerts~'*2fbackend*2ftext-search~'*2ffrontend)))**

*Links open CloudWatch Logs with recent entries*
EOT
          region = local.dashboard_properties.region
        }
      },

      # Widget 4: Recent Error Logs (last 1-2 hours)
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          query = "SOURCE '${join("' | SOURCE '", [for s in local.services : s.log_group])}' | fields @timestamp, @message, @logStream | filter @message like /ERROR/ or @message like /Exception/ or @message like /FATAL/ | filter @timestamp > date_sub(now(), interval 2 hour) | sort @timestamp desc | limit 20"
          region = local.dashboard_properties.region
          title  = "Recent Error Logs (Last 2 Hours)"
          view   = "table"
        }
      },

      # Widget 5: Service Status (up/down for ECS services)
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 6
        height = 6
        properties = {
          metrics = concat([
            for service in var.service_names : 
            ["AWS/ECS", "RunningTaskCount", "ServiceName", service, "ClusterName", var.cluster_name]
          ])
          view   = "singleValue"
          region = local.dashboard_properties.region
          title  = "Service Status (Running Tasks)"
          period = local.dashboard_properties.period
          stat   = "Average"
        }
      },
      {
        type   = "text"
        x      = 18
        y      = 6
        width  = 6
        height = 6
        properties = {
          markdown = <<-EOT
# Quick Troubleshooting

## Common Portfolio Issues

### 🔧 Service Not Starting
1. Check ECS task logs
2. Verify memory limits
3. Check port conflicts

### 🔧 High Memory Usage
1. Restart containers
2. Check for memory leaks
3. Scale down if needed

### 🔧 Log Access Issues
1. Verify log groups exist
2. Check IAM permissions
3. Confirm log retention

### 🔧 Portfolio Demo Prep
- All services showing 1 running task
- Memory usage < 70%
- No recent errors in logs
- All log links accessible

**Need Help?** Check ECS console for detailed task information.
EOT
          region = local.dashboard_properties.region
        }
      }
    ]
  })
}

resource "aws_cloudwatch_query_definition" "container_logs_access" {
  name = "${var.cluster_name}-container-logs-access"

  log_group_names = [for service in local.services : service.log_group]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @timestamp > date_sub(now(), interval 2 hour)
| sort @timestamp desc
| limit 100
EOF
}

resource "aws_cloudwatch_query_definition" "recent_error_logs" {
  name = "${var.cluster_name}-recent-error-logs"

  log_group_names = [for service in local.services : service.log_group]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /ERROR/ or @message like /Exception/ or @message like /FATAL/
| filter @timestamp > date_sub(now(), interval 2 hour)
| sort @timestamp desc
| limit 50
EOF
}

resource "aws_cloudwatch_query_definition" "current_session_logs" {
  name = "${var.cluster_name}-current-session-logs"

  log_group_names = [for service in local.services : service.log_group]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @timestamp > date_sub(now(), interval 30 minute)
| sort @timestamp desc
| limit 25
EOF
}

