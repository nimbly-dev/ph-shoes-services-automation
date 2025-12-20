output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.cloudwatch_alarms.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.cloudwatch_alarms.name
}

output "task_count_alarm_names" {
  description = "Names of the task count zero alarms"
  value       = [for alarm in aws_cloudwatch_metric_alarm.service_task_count_zero : alarm.alarm_name]
}

# REMOVED FOR COST OPTIMIZATION - Individual service CPU/memory alarms
# These outputs are no longer available as the alarms were removed to stay within free tier
output "cpu_alarm_names" {
  description = "Names of the CPU utilization alarms - removed for cost optimization"
  value       = []
}

output "memory_alarm_names" {
  description = "Names of the memory utilization alarms - removed for cost optimization"
  value       = []
}

output "cluster_cpu_alarm_name" {
  description = "Name of the cluster CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cluster_cpu_high.alarm_name
}

output "cluster_memory_alarm_name" {
  description = "Name of the cluster memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cluster_memory_high.alarm_name
}