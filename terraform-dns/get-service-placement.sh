#!/bin/bash
set -euo pipefail

# Get all running tasks
TASKS=$(aws ecs list-tasks --cluster ph-shoes-services-ecs --desired-status RUNNING --query "taskArns[*]" --output text)

# Get fallback IP (first available instance)
get_fallback_ip() {
  aws ec2 describe-instances \
    --filters "Name=tag:aws:autoscaling:groupName,Values=ph-shoes-services-ecs-asg" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text 2>/dev/null
}

FALLBACK_IP=$(get_fallback_ip)
if [ -z "$FALLBACK_IP" ] || [ "$FALLBACK_IP" = "None" ] || [ "$FALLBACK_IP" = "null" ]; then
  echo "ERROR: Unable to determine fallback IP from running ECS instances." >&2
  echo "ERROR: Aborting DNS update to avoid overwriting records with a stale/default IP." >&2
  exit 1
fi

if [ -z "$TASKS" ] || [ "$TASKS" = "None" ]; then
  # No tasks running - use fallback for all services
  echo "{\"frontend_ip\":\"$FALLBACK_IP\",\"accounts_ip\":\"$FALLBACK_IP\",\"catalog_ip\":\"$FALLBACK_IP\",\"alerts_ip\":\"$FALLBACK_IP\",\"text_search_ip\":\"$FALLBACK_IP\"}"
  exit 0
fi

# Function to get IP for a service
get_service_ip() {
  local service_pattern=$1
  
  # Get container instance ARN for this specific service
  local container_arn=$(aws ecs describe-tasks --cluster ph-shoes-services-ecs --tasks $TASKS \
    --query "tasks[?contains(group, '$service_pattern')].containerInstanceArn | [0]" --output text 2>/dev/null)
  
  if [ -z "$container_arn" ] || [ "$container_arn" = "None" ] || [ "$container_arn" = "null" ]; then
    echo "$FALLBACK_IP"
    return
  fi
  
  # Get container instance ID from ARN
  local container_id=$(echo "$container_arn" | sed 's|.*/||')
  
  # Get EC2 instance ID
  local ec2_id=$(aws ecs describe-container-instances --cluster ph-shoes-services-ecs \
    --container-instances "$container_id" --query "containerInstances[0].ec2InstanceId" --output text 2>/dev/null)
  
  if [ -z "$ec2_id" ] || [ "$ec2_id" = "None" ]; then
    echo "$FALLBACK_IP"
    return
  fi
  
  # Get public IP
  local public_ip=$(aws ec2 describe-instances --instance-ids "$ec2_id" \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text 2>/dev/null)
  
  if [ -z "$public_ip" ] || [ "$public_ip" = "None" ]; then
    echo "$FALLBACK_IP"
    return
  fi
  
  echo "$public_ip"
}

# Get IPs for each service (use actual service names from ECS)
FRONTEND_IP=$(get_service_ip "ph-shoes-services-automation-frontend")
ACCOUNTS_IP=$(get_service_ip "ph-shoes-services-automation-user-accounts")
CATALOG_IP=$(get_service_ip "ph-shoes-services-automation-catalog")
ALERTS_IP=$(get_service_ip "ph-shoes-services-automation-alerts")
TEXT_SEARCH_IP=$(get_service_ip "ph-shoes-services-automation-text-search")

echo "{\"frontend_ip\":\"$FRONTEND_IP\",\"accounts_ip\":\"$ACCOUNTS_IP\",\"catalog_ip\":\"$CATALOG_IP\",\"alerts_ip\":\"$ALERTS_IP\",\"text_search_ip\":\"$TEXT_SEARCH_IP\"}"
