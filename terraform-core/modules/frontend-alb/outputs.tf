output "alb_arn" {
  value       = aws_lb.this.arn
  description = "ALB ARN"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "ALB DNS"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "ALB security group"
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "Target group ARN"
}
