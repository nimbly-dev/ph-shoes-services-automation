# Dynamic DNS module for service-aware routing
# Routes each domain to the EC2 instance actually running that service

# Dynamic service discovery using external data sources with detailed logging
data "external" "service_instance" {
  for_each = var.services
  
  program = ["bash", "-c", <<-EOT
    # Enhanced service discovery with detailed logging
    SERVICE_NAME="${each.value.service_name}"
    CLUSTER_NAME="${var.cluster_name}"
    REGION="${var.aws_region}"
    
    echo "[DEBUG] Starting service discovery for: $SERVICE_NAME" >&2
    echo "[DEBUG] Cluster: $CLUSTER_NAME, Region: $REGION" >&2
    
    # Find which EC2 instance is running the specified service
    echo "[DEBUG] Querying ECS for running tasks..." >&2
    TASK_ARN=$(aws ecs list-tasks \
      --cluster $CLUSTER_NAME \
      --service-name $SERVICE_NAME \
      --region $REGION \
      --query 'taskArns[0]' \
      --output text 2>/dev/null || echo "null")
    
    echo "[DEBUG] Task ARN discovered: $TASK_ARN" >&2
    
    if [ "$TASK_ARN" != "null" ] && [ "$TASK_ARN" != "None" ] && [ "$TASK_ARN" != "" ]; then
      echo "[DEBUG] Service is running, discovering container instance..." >&2
      
      CONTAINER_INSTANCE_ARN=$(aws ecs describe-tasks \
        --cluster $CLUSTER_NAME \
        --tasks $TASK_ARN \
        --region $REGION \
        --query 'tasks[0].containerInstanceArn' \
        --output text)
      
      echo "[DEBUG] Container instance ARN: $CONTAINER_INSTANCE_ARN" >&2
      
      EC2_INSTANCE_ID=$(aws ecs describe-container-instances \
        --cluster $CLUSTER_NAME \
        --container-instances $CONTAINER_INSTANCE_ARN \
        --region $REGION \
        --query 'containerInstances[0].ec2InstanceId' \
        --output text)
      
      echo "[DEBUG] EC2 instance ID: $EC2_INSTANCE_ID" >&2
      
      PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids $EC2_INSTANCE_ID \
        --region $REGION \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
      
      echo "[DEBUG] Public IP discovered: $PUBLIC_IP" >&2
      echo "[INFO] Service $SERVICE_NAME routed to instance $EC2_INSTANCE_ID ($PUBLIC_IP)" >&2
      
      echo "{\"ip\": \"$PUBLIC_IP\", \"task_arn\": \"$TASK_ARN\", \"container_instance_arn\": \"$CONTAINER_INSTANCE_ARN\", \"ec2_instance_id\": \"$EC2_INSTANCE_ID\", \"service_status\": \"running\"}"
    else
      # Fallback to configured fallback IP if service not found or cluster scaled to zero
      echo "[WARN] Service $SERVICE_NAME not found or not running, using fallback IP: ${var.fallback_ip}" >&2
      
      # Check if fallback IP indicates scaled-to-zero scenario
      if [ "${var.fallback_ip}" = "192.0.2.1" ]; then
        echo "[INFO] Cluster appears to be scaled to zero - using maintenance mode IP" >&2
        echo "{\"ip\": \"${var.fallback_ip}\", \"task_arn\": \"null\", \"container_instance_arn\": \"null\", \"ec2_instance_id\": \"null\", \"service_status\": \"scaled_to_zero\"}"
      else
        echo "{\"ip\": \"${var.fallback_ip}\", \"task_arn\": \"null\", \"container_instance_arn\": \"null\", \"ec2_instance_id\": \"null\", \"service_status\": \"not_running\"}"
      fi
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
