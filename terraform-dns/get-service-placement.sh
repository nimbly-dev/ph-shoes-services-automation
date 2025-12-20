#!/bin/bash
set -e

# Get all running tasks and their container instances
TASKS=$(aws ecs list-tasks --cluster ph-shoes-services-ecs --desired-status RUNNING --query "taskArns[*]" --output text)

if [ -z "$TASKS" ]; then
  echo '{"frontend_ip":"127.0.0.1","accounts_ip":"127.0.0.1","catalog_ip":"127.0.0.1","alerts_ip":"127.0.0.1","text_search_ip":"127.0.0.1"}'
  exit 0
fi

# Get task details including service names and container instances
TASK_DETAILS=$(aws ecs describe-tasks --cluster ph-shoes-services-ecs --tasks $TASKS --query "tasks[*].{Group:group,ContainerInstanceArn:containerInstanceArn}" --output json)

# Get container instance to EC2 instance mapping
CONTAINER_INSTANCES=$(echo "$TASK_DETAILS" | jq -r '.[].ContainerInstanceArn' | sed 's|.*/||' | tr '\n' ' ')

if [ -n "$CONTAINER_INSTANCES" ]; then
  INSTANCE_MAPPING=$(aws ecs describe-container-instances --cluster ph-shoes-services-ecs --container-instances $CONTAINER_INSTANCES --query "containerInstances[*].{ContainerInstanceArn:containerInstanceArn,Ec2InstanceId:ec2InstanceId}" --output json)
  
  # Get EC2 instance IPs
  EC2_IDS=$(echo "$INSTANCE_MAPPING" | jq -r '.[].Ec2InstanceId' | tr '\n' ' ')
  EC2_DETAILS=$(aws ec2 describe-instances --instance-ids $EC2_IDS --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PublicIpAddress:PublicIpAddress}" --output json | jq '[.[][]]')
  
  # Build service to IP mapping
  FRONTEND_IP=$(echo "$TASK_DETAILS" | jq -r '.[] | select(.Group | contains("frontend")) | .ContainerInstanceArn' | sed 's|.*/||' | head -1)
  ACCOUNTS_IP=$(echo "$TASK_DETAILS" | jq -r '.[] | select(.Group | contains("user-accounts")) | .ContainerInstanceArn' | sed 's|.*/||' | head -1)
  CATALOG_IP=$(echo "$TASK_DETAILS" | jq -r '.[] | select(.Group | contains("catalog")) | .ContainerInstanceArn' | sed 's|.*/||' | head -1)
  ALERTS_IP=$(echo "$TASK_DETAILS" | jq -r '.[] | select(.Group | contains("alerts")) | .ContainerInstanceArn' | sed 's|.*/||' | head -1)
  TEXT_SEARCH_IP=$(echo "$TASK_DETAILS" | jq -r '.[] | select(.Group | contains("text-search")) | .ContainerInstanceArn' | sed 's|.*/||' | head -1)
  
  # Convert container instance IDs to EC2 IPs
  get_ip_for_container() {
    local container_id=$1
    if [ -n "$container_id" ]; then
      local ec2_id=$(echo "$INSTANCE_MAPPING" | jq -r ".[] | select(.ContainerInstanceArn | contains(\"$container_id\")) | .Ec2InstanceId")
      echo "$EC2_DETAILS" | jq -r ".[] | select(.InstanceId == \"$ec2_id\") | .PublicIpAddress"
    else
      echo "127.0.0.1"
    fi
  }
  
  FRONTEND_IP_ADDR=$(get_ip_for_container "$FRONTEND_IP")
  ACCOUNTS_IP_ADDR=$(get_ip_for_container "$ACCOUNTS_IP")
  CATALOG_IP_ADDR=$(get_ip_for_container "$CATALOG_IP")
  ALERTS_IP_ADDR=$(get_ip_for_container "$ALERTS_IP")
  TEXT_SEARCH_IP_ADDR=$(get_ip_for_container "$TEXT_SEARCH_IP")
  
  # Default to first available IP if service not found
  FALLBACK_IP=$(echo "$EC2_DETAILS" | jq -r '.[0].PublicIpAddress // "127.0.0.1"')
  
  echo "{\"frontend_ip\":\"${FRONTEND_IP_ADDR:-$FALLBACK_IP}\",\"accounts_ip\":\"${ACCOUNTS_IP_ADDR:-$FALLBACK_IP}\",\"catalog_ip\":\"${CATALOG_IP_ADDR:-$FALLBACK_IP}\",\"alerts_ip\":\"${ALERTS_IP_ADDR:-$FALLBACK_IP}\",\"text_search_ip\":\"${TEXT_SEARCH_IP_ADDR:-$FALLBACK_IP}\"}"
else
  echo '{"frontend_ip":"127.0.0.1","accounts_ip":"127.0.0.1","catalog_ip":"127.0.0.1","alerts_ip":"127.0.0.1","text_search_ip":"127.0.0.1"}'
fi