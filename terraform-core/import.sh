#!/bin/bash
terraform import 'module.frontend_service[0].aws_cloudwatch_log_group.service[0]' /ecs/ph-shoes-services-automation-frontend
terraform import 'module.frontend_service[0].aws_security_group.service' sg-0ec9d97c1973b91b0
terraform import 'module.frontend_service[0].aws_iam_role.execution[0]' ph-shoes-services-automation-frontend-execution
terraform import 'module.frontend_service[0].aws_iam_role.task[0]' ph-shoes-services-automation-frontend-task
terraform import 'module.frontend_alb[0].aws_security_group.alb' $(aws ec2 describe-security-groups --filters "Name=group-name,Values=*ph-shoes-services-automation-frontend-alb-sg*" --region ap-southeast-1 --query 'SecurityGroups[0].GroupId' --output text)
terraform import 'module.frontend_alb[0].aws_lb.this' arn:aws:elasticloadbalancing:ap-southeast-1:101679083819:loadbalancer/app/ph-shoes-services-automation-fro/34d802137d7a6097
terraform import 'module.frontend_alb[0].aws_lb_target_group.this' arn:aws:elasticloadbalancing:ap-southeast-1:101679083819:targetgroup/ph-shoes-services-automation-fro/3a13cad29c92454d
terraform import 'module.frontend_alb[0].aws_lb_listener.https' $(aws elbv2 describe-listeners --load-balancer-arn arn:aws:elasticloadbalancing:ap-southeast-1:101679083819:loadbalancer/app/ph-shoes-services-automation-fro/34d802137d7a6097 --region ap-southeast-1 --query 'Listeners[?Port==`443`].ListenerArn' --output text)
terraform import 'module.frontend_alb[0].aws_lb_listener.http' $(aws elbv2 describe-listeners --load-balancer-arn arn:aws:elasticloadbalancing:ap-southeast-1:101679083819:loadbalancer/app/ph-shoes-services-automation-fro/34d802137d7a6097 --region ap-southeast-1 --query 'Listeners[?Port==`80`].ListenerArn' --output text)
