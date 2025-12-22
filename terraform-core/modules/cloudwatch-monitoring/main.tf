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

# Critical alarm only
resource "aws_cloudwatch_metric_alarm" "instance_failure_critical" {
  alarm_name          = "${var.cluster_name}-instance-failure-critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "CRITICAL: t3.micro instance is unavailable - portfolio project cannot function"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = var.tags
}

# Other alarms omitted to reduce noise and cost.

