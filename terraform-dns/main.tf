# Data sources to get current EC2 instance IPs and ECS task placement
data "aws_instances" "ecs_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["ph-shoes-services-ecs-asg"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "aws_route53_zone" "frontend" {
  name         = var.domain_name
  private_zone = false
}

# Get ECS tasks to determine service placement
data "aws_ecs_cluster" "main" {
  cluster_name = "ph-shoes-services-ecs"
}

# Data source to get running tasks and their placement
data "external" "service_placement" {
  program = ["bash", "-c", <<-EOT
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
EOT
  ]
}

# Route 53 records with smart service-to-instance routing (only when not using Cloudflare)
resource "aws_route53_record" "frontend" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.frontend_ip]
}

resource "aws_route53_record" "accounts" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "accounts.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.accounts_ip]
}

resource "aws_route53_record" "catalog" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "catalog.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.catalog_ip]
}

resource "aws_route53_record" "alerts" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "alerts.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.alerts_ip]
}

resource "aws_route53_record" "text_search" {
  count   = var.use_cloudflare_dns ? 0 : 1
  zone_id = data.aws_route53_zone.frontend.zone_id
  name    = "text-search.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.external.service_placement.result.text_search_ip]
}

# Cloudflare DNS records with smart service-to-instance routing
# Root domain A record - points to frontend instance
resource "cloudflare_record" "frontend" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "@"  # @ represents the root domain
  type            = "A"
  content         = data.external.service_placement.result.frontend_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Frontend service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

# Smart subdomain routing - each subdomain points to the instance running that service
resource "cloudflare_record" "accounts" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "accounts"
  type            = "A"
  content         = data.external.service_placement.result.accounts_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "User accounts service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

resource "cloudflare_record" "catalog" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "catalog"
  type            = "A"
  content         = data.external.service_placement.result.catalog_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Catalog service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

resource "cloudflare_record" "alerts" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "alerts"
  type            = "A"
  content         = data.external.service_placement.result.alerts_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Alerts service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}

resource "cloudflare_record" "text_search" {
  count           = var.use_cloudflare_dns ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "text-search"
  type            = "A"
  content         = data.external.service_placement.result.text_search_ip
  ttl             = 1     # TTL must be 1 when proxied=true (automatic)
  proxied         = true  # Enable Cloudflare proxy for SSL, DDoS protection, and caching
  comment         = "Text search service routing - managed by terraform-dns workflow"
  allow_overwrite = true
}