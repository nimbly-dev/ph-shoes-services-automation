#!/bin/bash
set -e

# Get all running tasks
TASKS=$(aws ecs list-tasks --cluster ph-shoes-services-ecs --desired-status RUNNING --query "taskArns[*]" --output text)

if [ -z "$TASKS" ]; then
  # No tasks - get first available instance IP
  FALLBACK=$(aws ec2 describe-instances \
    --filters "Name=tag:aws:autoscaling:groupName,Values=ph-shoes-services-ecs-asg" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text 2>/dev/null || echo "127.0.0.1")
  echo "{\"frontend_ip\":\"$FALLBACK\",\"accounts_ip\":\"$FALLBACK\",\"catalog_ip\":\"$FALLBACK\",\"alerts_ip\":\"$FALLBACK\",\"text_search_ip\":\"$FALLBACK\"}"
  exit 0
fi

# Function to get IP for a service
get_service_ip() {
  local service_pattern=$1
  
  # Get container instance for this service
  local container_arn=$(aws ecs describe-tasks --cluster ph-shoes-services-ecs --tasks $TASKS \
    --query "tasks[?contains(group, '$service_pattern')].containerInstanceArn | [0]" --output text)
  
  if [ -n "$container_arn" ] && [ "$container_arn" != "None" ]; then
    # Get container instance ID
    local container_id=$(echo "$container_arn" | sed 's|.*/||')
    
    # Get EC2 instance ID
    local ec2_id=$(aws ecs describe-container-instances --cluster ph-shoes-services-ecs \
      --container-instances "$container_id" --query "containerInstances[0].ec2InstanceId" --output text)
    
    if [ -n "$ec2_id" ] && [ "$ec2_id" != "None" ]; then
      # Get public IP
      local public_ip=$(aws ec2 describe-instances --instance-ids "$ec2_id" \
        --query "Reservations[0].Instances[0].PublicIpAddress" --output text 2>/dev/null)
      
      if [ -n "$public_ip" ] && [ "$public_ip" != "None" ]; then
        echo "$public_ip"
        return
      fi
    fi
  fi
  
  # Fallback to first available instance IP
  aws ec2 describe-instances \
    --filters "Name=tag:aws:autoscaling:groupName,Values=ph-shoes-services-ecs-asg" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text 2>/dev/null || echo "127.0.0.1"
}

# Get IPs for each service
FRONTEND_IP=$(get_service_ip "frontend")
ACCOUNTS_IP=$(get_service_ip "user-accounts")
CATALOG_IP=$(get_service_ip "catalog")
ALERTS_IP=$(get_service_ip "alerts")
TEXT_SEARCH_IP=$(get_service_ip "text-search")

echo "{\"frontend_ip\":\"$FRONTEND_IP\",\"accounts_ip\":\"$ACCOUNTS_IP\",\"catalog_ip\":\"$CATALOG_IP\",\"alerts_ip\":\"$ALERTS_IP\",\"text_search_ip\":\"$TEXT_SEARCH_IP\"}"