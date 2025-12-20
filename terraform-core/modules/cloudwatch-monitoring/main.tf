# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.cluster_name}-cloudwatch-alarms"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ESSENTIAL ALARMS ONLY - Cost Optimized for Free Tier (7 total)

# ECS Service Task Count Alarms - CRITICAL (5 alarms)
# These are essential to know when services are completely down
resource "aws_cloudwatch_metric_alarm" "service_task_count_zero" {
  for_each = toset(var.service_names)

  alarm_name          = "${each.value}-task-count-zero"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert when ${each.value} has no running tasks"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = each.value
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

# ECS Cluster CPU Utilization Alarm - ESSENTIAL (1 alarm)
# Cluster-level monitoring covers all services
resource "aws_cloudwatch_metric_alarm" "cluster_cpu_high" {
  alarm_name          = "${var.cluster_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Alert when cluster CPU utilization exceeds ${var.cpu_threshold}%"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

# ECS Cluster Memory Utilization Alarm - ESSENTIAL (1 alarm)
# Cluster-level monitoring covers all services
resource "aws_cloudwatch_metric_alarm" "cluster_memory_high" {
  alarm_name          = "${var.cluster_name}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "Alert when cluster memory utilization exceeds ${var.memory_threshold}%"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}

# REMOVED FOR COST OPTIMIZATION:
# - Per-Service CPU Utilization Alarms (5 alarms) - Redundant with cluster-level monitoring
# - Per-Service Memory Utilization Alarms (5 alarms) - Redundant with cluster-level monitoring
# 
# JUSTIFICATION (Amazon Q Rule #6 - Cost Optimization):
# - Cluster-level CPU/memory alarms provide sufficient coverage
# - Individual service alarms are nice-to-have but not critical
# - Task count alarms are more important for service availability
# - This reduces from 17 to 7 alarms, staying within free tier limit
