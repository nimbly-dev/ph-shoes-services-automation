# CloudWatch Dashboards Module - Cost Optimized for Free Tier
# Implements essential monitoring dashboards within AWS free tier limits

locals {
  # Service configuration for dashboard widgets
  services = {
    frontend      = { port = 8080, container_port = 80 }
    user-accounts = { port = 8082, container_port = 8082 }
    catalog       = { port = 8083, container_port = 8080 }
    alerts        = { port = 8084, container_port = 8080 }
    text-search   = { port = 8085, container_port = 8080 }
  }

  # Common dashboard properties
  dashboard_properties = {
    period_override = "inherit"
    stat            = "Average"
    region          = data.aws_region.current.name
  }
}

data "aws_region" "current" {}

# System Overview Dashboard - Essential metrics only
resource "aws_cloudwatch_dashboard" "system_overview" {
  dashboard_name = "${var.cluster_name}-system-overview"

  dashboard_body = jsonencode({
    widgets = [
      # Cluster Health Overview (Top Row)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ClusterName", var.cluster_name],
            [".", "CPUUtilization", ".", "."],
            [".", "MemoryUtilization", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = local.dashboard_properties.region
          title   = "ECS Cluster Health & Resource Utilization"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      # Cost Tracking Widget (simplified)
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ]
          view   = "singleValue"
          region = local.dashboard_properties.region
          title  = "Current Month Estimated Charges"
          period = 3600
          stat   = "Maximum"
        }
      },
      # Auto Scaling Activity (Second Row)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "GroupInServiceInstances", ".", "."]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "Auto Scaling Activity"
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      # Recent Log Activity (simplified)
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | fields @timestamp, @logStream | stats count() by bin(1h) | sort @timestamp desc | limit 10"
          region = local.dashboard_properties.region
          title  = "Log Activity Summary"
          view   = "table"
        }
      }
    ]
  })
}

# Service Performance Dashboard - Essential metrics only
resource "aws_cloudwatch_dashboard" "service_performance" {
  dashboard_name = "${var.cluster_name}-service-performance"

  dashboard_body = jsonencode({
    widgets = [
      # Cluster Performance Overview (Top Row)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name],
            [".", "MemoryUtilization", ".", "."]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "Cluster Performance Overview"
          period = 300
          stat   = "Average"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      # Service Health Summary
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUReservation", "ClusterName", var.cluster_name],
            [".", "MemoryReservation", ".", "."]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "Resource Reservation"
          period = 300
          stat   = "Average"
        }
      },
      # EC2 Instance Performance (Second Row)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "EC2 Instance Performance"
          period = 300
          stat   = "Average"
        }
      },
      # Log Insights - Essential Errors Only
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | fields @timestamp, @message | filter @message like /ERROR/ or @message like /Exception/ | stats count() by bin(1h) | sort @timestamp desc | limit 10"
          region = local.dashboard_properties.region
          title  = "Error Count Summary"
          view   = "table"
        }
      }
    ]
  })
}

# Infrastructure Dashboard - Cost optimized
resource "aws_cloudwatch_dashboard" "infrastructure" {
  dashboard_name = "${var.cluster_name}-infrastructure"

  dashboard_body = jsonencode({
    widgets = [
      # EC2 Instance Health (Top Row)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "EC2 Instance Health - CPU & Network I/O"
          period = 300
          stat   = "Average"
        }
      },
      # ECS Cluster Utilization
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUReservation", "ClusterName", var.cluster_name],
            [".", "MemoryReservation", ".", "."]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "ECS Cluster Utilization"
          period = 300
          stat   = "Average"
        }
      },
      # Cost Tracking (Second Row)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ]
          view   = "timeSeries"
          region = local.dashboard_properties.region
          title  = "Total Estimated Charges"
          period = 3600
          stat   = "Maximum"
        }
      },
      # Log Activity Summary
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          query  = "SOURCE '/backend/user-accounts' | SOURCE '/backend/catalog' | SOURCE '/backend/alerts' | SOURCE '/backend/text-search' | SOURCE '/frontend' | fields @timestamp | stats count() by bin(1h) | sort @timestamp desc | limit 10"
          region = local.dashboard_properties.region
          title  = "Log Activity Summary"
          view   = "table"
        }
      }
    ]
  })
}

# Essential CloudWatch Insights Query - Cost Optimized (1 query only)
resource "aws_cloudwatch_query_definition" "essential_errors" {
  name = "${var.cluster_name}-essential-errors"

  log_group_names = [
    "/backend/user-accounts",
    "/backend/catalog",
    "/backend/alerts",
    "/backend/text-search",
    "/frontend"
  ]

  query_string = <<EOF
fields @timestamp, @message, @logStream
| filter @message like /ERROR/ or @message like /Exception/ or @message like /Failed/
| stats count() by @logStream
| sort @timestamp desc
| limit 20
EOF
}