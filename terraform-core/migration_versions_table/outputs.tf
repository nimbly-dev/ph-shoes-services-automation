output "table_name" {
  description = "Name of the migration versions table"
  value       = aws_dynamodb_table.migration_versions.name
}

output "table_arn" {
  description = "ARN of the migration versions table"
  value       = aws_dynamodb_table.migration_versions.arn
}
