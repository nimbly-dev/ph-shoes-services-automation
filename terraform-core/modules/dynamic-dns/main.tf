# Dynamic DNS module for service-aware routing
# Routes each domain to the EC2 instance actually running that service

# Dynamic service discovery using external data sources
data "external" "service_instance" {
  for_each = var.services
  
  program = ["bash", "-c", <<-EOT
    # Find which EC2 instance is running the specified service
    TASK_ARN=$(aws ecs list-tasks \
      --cluster ${var.cluster_name} \
      --service-name ${each.value.service_name} \
      --region ${var.aws_region} \
      --query 'taskArns[0]' \
      --output text 2>/dev/null || echo "null")
    
    if [ "$TASK_ARN" != "null" ] && [ "$TASK_ARN" != "None" ] && [ "$TASK_ARN" != "" ]; then
      CONTAINER_INSTANCE_ARN=$(aws ecs describe-tasks \
        --cluster ${var.cluster_name} \
        --tasks $TASK_ARN \
        --region ${var.aws_region} \
        --query 'tasks[0].containerInstanceArn' \
        --output text)
      
      EC2_INSTANCE_ID=$(aws ecs describe-container-instances \
        --cluster ${var.cluster_name} \
        --container-instances $CONTAINER_INSTANCE_ARN \
        --region ${var.aws_region} \
        --query 'containerInstances[0].ec2InstanceId' \
        --output text)
      
      PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids $EC2_INSTANCE_ID \
        --region ${var.aws_region} \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
      
      echo "{\"ip\": \"$PUBLIC_IP\"}"
    else
      # Fallback to first available instance if service not found
      echo "{\"ip\": \"${var.fallback_ip}\"}"
    fi
  EOT
  ]
}

# Create Cloudflare DNS records dynamically
resource "cloudflare_record" "service" {
  for_each = var.services
  
  zone_id = var.cloudflare_zone_id
  name    = each.value.domain
  content = data.external.service_instance[each.key].result.ip
  type    = "A"
  ttl     = 1     # TTL must be 1 when proxied is true
  proxied = true  # Enable Cloudflare proxy for HTTPS
  comment = "${each.value.description} - Dynamic routing"
}
