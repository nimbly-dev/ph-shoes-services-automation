output "id" {
  value       = aws_servicecatalogappregistry_application.this.id
  description = "Application identifier"
}

output "arn" {
  value       = aws_servicecatalogappregistry_application.this.arn
  description = "ARN of the AppRegistry application"
}
