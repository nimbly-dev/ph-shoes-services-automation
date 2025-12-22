output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.cloudwatch_alarms.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.cloudwatch_alarms.name
}

output "instance_failure_alarm_name" {
  description = "Name of the critical instance failure alarm"
  value       = aws_cloudwatch_metric_alarm.instance_failure_critical.alarm_name
}

# REMOVED OUTPUTS - Alarms no longer exist after cleanup
output "task_count_alarm_names" {
  description = "Names of the task count zero alarms - removed for portfolio simplification"
  value       = []
}

output "cpu_alarm_names" {
  description = "Names of the CPU utilization alarms - removed for portfolio simplification"
  value       = []
}

output "memory_alarm_names" {
  description = "Names of the memory utilization alarms - removed for portfolio simplification"
  value       = []
}

output "cluster_cpu_alarm_name" {
  description = "Name of the cluster CPU utilization alarm - removed for portfolio simplification"
  value       = ""
}

output "cluster_memory_alarm_name" {
  description = "Name of the cluster memory utilization alarm - removed for portfolio simplification"
  value       = ""
}
