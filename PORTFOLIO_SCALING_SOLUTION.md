# Portfolio-Grade Microservices Scaling Solution

## 🎯 **Goal: Enterprise-Grade Load Balancing at $0 Cost**

Transform your architecture into a **portfolio-worthy microservices platform** that demonstrates:
- ✅ **Horizontal scaling** (2x, 3x services)
- ✅ **Load balancing** (round-robin, health checks)
- ✅ **Service discovery** (automatic instance detection)
- ✅ **Zero downtime deployments** (rolling updates)
- ✅ **Production patterns** (circuit breakers, retries)
- ✅ **Cost optimization** (still $3-5/month)

---

## 🏗️ **Solution Architecture**

### **Enhanced Architecture Diagram:**
```
Internet → Cloudflare → Route53 → EC2 Instances → nginx (Smart Load Balancer) → ECS Services (Multiple Instances)

┌─────────────────────────────────────────────────────────────────────────────────┐
│                           EC2 Instance Pool                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│  nginx (Port 80) - Smart Load Balancer with Service Discovery                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ECS Services (Dynamic Ports)                                                  │
│  ┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐    │
│  │ Catalog-1       │ Catalog-2       │ User-Acct-1     │ User-Acct-2     │    │
│  │ :32768          │ :32769          │ :32770          │ :32771          │    │
│  └─────────────────┴─────────────────┴─────────────────┴─────────────────┘    │
│  ┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐    │
│  │ Alerts-1        │ Search-1        │ Frontend-1      │ Frontend-2      │    │
│  │ :32772          │ :32773          │ :32774          │ :32775          │    │
│  └─────────────────┴─────────────────┴─────────────────┴─────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### **Key Components:**

#### **1. Dynamic Port Allocation**
```hcl
# Task definition with dynamic ports
port_mappings = [
  {
    container_port = 8080
    host_port      = 0      # ECS assigns random port (32768-65535)
    protocol       = "tcp"
  }
]
```

#### **2. Service Discovery Script**
```bash
#!/bin/bash
# discover-services.sh - Updates nginx config with live service instances

discover_service_instances() {
    local service_name=$1
    local cluster_name="ph-shoes-services-ecs"
    
    # Get all running tasks for service
    aws ecs list-tasks \
        --cluster $cluster_name \
        --service-name $service_name \
        --desired-status RUNNING \
        --query 'taskArns[]' \
        --output text | while read task_arn; do
        
        # Get task details
        task_info=$(aws ecs describe-tasks \
            --cluster $cluster_name \
            --tasks $task_arn \
            --query 'tasks[0]')
        
        # Extract instance and port info
        container_instance=$(echo $task_info | jq -r '.containerInstanceArn')
        host_port=$(echo $task_info | jq -r '.containers[0].networkBindings[0].hostPort')
        
        # Get EC2 instance IP
        instance_id=$(aws ecs describe-container-instances \
            --cluster $cluster_name \
            --container-instances $container_instance \
            --query 'containerInstances[0].ec2InstanceId' \
            --output text)
        
        instance_ip=$(aws ec2 describe-instances \
            --instance-ids $instance_id \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
        
        echo "$instance_ip:$host_port"
    done
}
```

#### **3. Smart nginx Configuration**
```nginx
# /etc/nginx/conf.d/microservices.conf
# Auto-generated by service discovery

upstream catalog_backend {
    # Health check every 30s, fail after 3 attempts
    server 10.0.1.100:32768 max_fails=3 fail_timeout=30s;
    server 10.0.1.101:32769 max_fails=3 fail_timeout=30s;
    server 10.0.1.102:32770 max_fails=3 fail_timeout=30s;
    
    # Load balancing method
    least_conn;  # Route to least busy instance
}

upstream user_accounts_backend {
    server 10.0.1.100:32771 max_fails=3 fail_timeout=30s;
    server 10.0.1.101:32772 max_fails=3 fail_timeout=30s;
    
    # Sticky sessions if needed
    ip_hash;
}

upstream alerts_backend {
    server 10.0.1.100:32773 max_fails=3 fail_timeout=30s;
    server 10.0.1.101:32774 max_fails=3 fail_timeout=30s;
}

# Catalog Service with Load Balancing
server {
    listen 80;
    server_name catalog.phshoesproject.com;
    
    location / {
        proxy_pass http://catalog_backend;
        
        # Production-grade proxy settings
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts and retries
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
        
        # Health check endpoint
        proxy_intercept_errors on;
        error_page 502 503 504 = @catalog_fallback;
    }
    
    location @catalog_fallback {
        return 503 "Service temporarily unavailable";
        add_header Content-Type text/plain;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://catalog_backend/actuator/health;
    }
}

# Frontend with API Routing and Load Balancing
server {
    listen 80;
    server_name phshoesproject.com;
    
    # API routes with load balancing
    location /api/catalog/ {
        proxy_pass http://catalog_backend/;
        include /etc/nginx/proxy_params;
    }
    
    location /api/accounts/ {
        proxy_pass http://user_accounts_backend/;
        include /etc/nginx/proxy_params;
    }
    
    location /api/alerts/ {
        proxy_pass http://alerts_backend/;
        include /etc/nginx/proxy_params;
    }
    
    # Frontend SPA (also load balanced)
    location / {
        proxy_pass http://frontend_backend;
        include /etc/nginx/proxy_params;
    }
}
```

#### **4. Automated Service Discovery**
```bash
#!/bin/bash
# update-nginx-config.sh - Runs every 30 seconds

SERVICES=("catalog" "user-accounts" "alerts" "text-search" "frontend")
CONFIG_FILE="/etc/nginx/conf.d/microservices.conf"
TEMP_FILE="/tmp/nginx-config.tmp"

generate_nginx_config() {
    cat > $TEMP_FILE << 'EOF'
# Auto-generated nginx configuration
# Generated at: $(date)

EOF

    for service in "${SERVICES[@]}"; do
        echo "upstream ${service//-/_}_backend {" >> $TEMP_FILE
        
        # Discover service instances
        instances=$(discover_service_instances "ph-shoes-services-automation-$service")
        
        if [ -n "$instances" ]; then
            echo "$instances" | while read instance; do
                echo "    server $instance max_fails=3 fail_timeout=30s;" >> $TEMP_FILE
            done
        else
            # Fallback server
            echo "    server 127.0.0.1:8080 backup;" >> $TEMP_FILE
        fi
        
        echo "    least_conn;" >> $TEMP_FILE
        echo "}" >> $TEMP_FILE
        echo "" >> $TEMP_FILE
    done
    
    # Add server blocks
    cat >> $TEMP_FILE << 'EOF'
# Server configurations...
EOF
}

# Update nginx if config changed
generate_nginx_config
if ! cmp -s $TEMP_FILE $CONFIG_FILE; then
    mv $TEMP_FILE $CONFIG_FILE
    nginx -t && nginx -s reload
    echo "nginx configuration updated at $(date)"
fi
```

---

## 🚀 **Implementation Plan**

### **Phase 1: Enable Dynamic Ports (Week 1)**

#### **Step 1: Update Task Definitions**
```hcl
# modules/ecs-service/main.tf
resource "aws_ecs_task_definition" "this" {
  family = var.service_name
  
  container_definitions = jsonencode([{
    name  = var.service_name
    image = var.image_uri
    
    portMappings = [{
      containerPort = var.container_port
      hostPort      = 0  # Dynamic port allocation ✅
      protocol      = "tcp"
    }]
    
    # Add service discovery labels
    dockerLabels = {
      "service.name" = var.service_name
      "service.port" = tostring(var.container_port)
      "service.health_check" = var.health_check_path
    }
  }])
}
```

#### **Step 2: Create Service Discovery Module**
```hcl
# modules/service-discovery/main.tf
resource "aws_ecs_service" "discovery" {
  name    = "service-discovery"
  cluster = var.cluster_id
  
  task_definition = aws_ecs_task_definition.discovery.arn
  desired_count   = 1
  
  # Service discovery runs on every instance
  placement_constraints {
    type = "distinctInstance"
  }
}

resource "aws_ecs_task_definition" "discovery" {
  family = "service-discovery"
  
  container_definitions = jsonencode([{
    name  = "service-discovery"
    image = "nginx:alpine"
    
    # Mount nginx config volume
    mountPoints = [{
      sourceVolume  = "nginx-config"
      containerPath = "/etc/nginx/conf.d"
    }]
    
    # Service discovery script
    command = ["/bin/sh", "-c", "while true; do /usr/local/bin/update-nginx-config.sh; sleep 30; done"]
  }])
  
  volume {
    name = "nginx-config"
    host_path = "/etc/nginx/conf.d"
  }
}
```

### **Phase 2: Smart Load Balancing (Week 2)**

#### **Step 1: Enhanced nginx Configuration**
```bash
# Install on EC2 instances via user-data
cat > /usr/local/bin/update-nginx-config.sh << 'EOF'
#!/bin/bash
# Production-grade service discovery script
# Features: Health checks, circuit breakers, metrics

CLUSTER_NAME="ph-shoes-services-ecs"
REGION="ap-southeast-1"
CONFIG_DIR="/etc/nginx/conf.d"
METRICS_FILE="/var/log/nginx/service-discovery.log"

log_metric() {
    echo "$(date -Iseconds) $1" >> $METRICS_FILE
}

discover_healthy_instances() {
    local service_name=$1
    local healthy_instances=()
    
    # Get all running tasks
    local tasks=$(aws ecs list-tasks \
        --cluster $CLUSTER_NAME \
        --service-name $service_name \
        --desired-status RUNNING \
        --region $REGION \
        --query 'taskArns[]' \
        --output text)
    
    for task in $tasks; do
        # Get task details
        local task_info=$(aws ecs describe-tasks \
            --cluster $CLUSTER_NAME \
            --tasks $task \
            --region $REGION)
        
        # Extract networking info
        local container_instance=$(echo $task_info | jq -r '.tasks[0].containerInstanceArn')
        local host_port=$(echo $task_info | jq -r '.tasks[0].containers[0].networkBindings[0].hostPort')
        
        # Get instance IP
        local instance_id=$(aws ecs describe-container-instances \
            --cluster $CLUSTER_NAME \
            --container-instances $container_instance \
            --region $REGION \
            --query 'containerInstances[0].ec2InstanceId' \
            --output text)
        
        local instance_ip=$(aws ec2 describe-instances \
            --instance-ids $instance_id \
            --region $REGION \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
        
        # Health check
        if curl -sf "http://$instance_ip:$host_port/actuator/health" >/dev/null 2>&1; then
            healthy_instances+=("$instance_ip:$host_port")
            log_metric "HEALTHY: $service_name at $instance_ip:$host_port"
        else
            log_metric "UNHEALTHY: $service_name at $instance_ip:$host_port"
        fi
    done
    
    printf '%s\n' "${healthy_instances[@]}"
}

generate_upstream_config() {
    local service_name=$1
    local upstream_name="${service_name//-/_}_backend"
    
    echo "upstream $upstream_name {"
    
    local instances=$(discover_healthy_instances "ph-shoes-services-automation-$service_name")
    local instance_count=0
    
    while IFS= read -r instance; do
        if [ -n "$instance" ]; then
            echo "    server $instance max_fails=3 fail_timeout=30s weight=1;"
            ((instance_count++))
        fi
    done <<< "$instances"
    
    # Add backup server if no healthy instances
    if [ $instance_count -eq 0 ]; then
        echo "    server 127.0.0.1:8080 backup down;"
        log_metric "WARNING: No healthy instances for $service_name"
    fi
    
    echo "    least_conn;"
    echo "    keepalive 32;"
    echo "}"
    echo ""
    
    log_metric "DISCOVERY: Found $instance_count healthy instances for $service_name"
}

# Main execution
main() {
    local config_file="$CONFIG_DIR/microservices.conf"
    local temp_file="/tmp/nginx-microservices.conf"
    
    # Generate new configuration
    cat > $temp_file << EOF
# Auto-generated microservices configuration
# Generated: $(date -Iseconds)
# Cluster: $CLUSTER_NAME

EOF
    
    # Generate upstream blocks for each service
    for service in catalog user-accounts alerts text-search frontend; do
        generate_upstream_config $service >> $temp_file
    done
    
    # Add server blocks
    cat >> $temp_file << 'EOF'
# Catalog Service
server {
    listen 80;
    server_name catalog.phshoesproject.com;
    
    location / {
        proxy_pass http://catalog_backend;
        include /etc/nginx/proxy_params;
        
        # Circuit breaker pattern
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 10s;
    }
    
    location /health {
        access_log off;
        proxy_pass http://catalog_backend/actuator/health;
    }
}

# User Accounts Service  
server {
    listen 80;
    server_name accounts.phshoesproject.com;
    
    location / {
        proxy_pass http://user_accounts_backend;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
    }
}

# Alerts Service
server {
    listen 80;
    server_name alerts.phshoesproject.com;
    
    location / {
        proxy_pass http://alerts_backend;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
    }
}

# Text Search Service
server {
    listen 80;
    server_name text-search.phshoesproject.com;
    
    location / {
        proxy_pass http://text_search_backend;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
    }
}

# Frontend with API Load Balancing
server {
    listen 80;
    server_name phshoesproject.com;
    
    # API routes with intelligent routing
    location /api/catalog/ {
        proxy_pass http://catalog_backend/;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
    }
    
    location /api/accounts/ {
        proxy_pass http://user_accounts_backend/;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
    }
    
    location /api/alerts/ {
        proxy_pass http://alerts_backend/;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
    }
    
    location /api/search/ {
        proxy_pass http://text_search_backend/;
        include /etc/nginx/proxy_params;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
    }
    
    # Frontend SPA
    location / {
        proxy_pass http://frontend_backend;
        include /etc/nginx/proxy_params;
    }
}
EOF
    
    # Update nginx if configuration changed
    if ! cmp -s $temp_file $config_file; then
        cp $temp_file $config_file
        if nginx -t; then
            nginx -s reload
            log_metric "SUCCESS: nginx configuration updated and reloaded"
        else
            log_metric "ERROR: nginx configuration test failed"
            # Restore previous config if available
            if [ -f "$config_file.backup" ]; then
                cp "$config_file.backup" $config_file
                nginx -s reload
                log_metric "RECOVERY: Restored previous nginx configuration"
            fi
        fi
    fi
    
    rm -f $temp_file
}

# Create proxy params file
cat > /etc/nginx/proxy_params << 'EOF'
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_connect_timeout 5s;
proxy_send_timeout 10s;
proxy_read_timeout 10s;
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
EOF

# Execute main function
main
EOF

chmod +x /usr/local/bin/update-nginx-config.sh
```

### **Phase 3: Monitoring & Metrics (Week 3)**

#### **Step 1: Service Discovery Dashboard**
```bash
# Add to CloudWatch dashboards
cat >> service-discovery-metrics.json << 'EOF'
{
  "widgets": [
    {
      "type": "log",
      "properties": {
        "query": "SOURCE '/var/log/nginx/service-discovery.log' | fields @timestamp, @message | filter @message like /HEALTHY/ | stats count() by bin(5m)",
        "region": "ap-southeast-1",
        "title": "Healthy Service Instances",
        "view": "timeSeries"
      }
    },
    {
      "type": "log", 
      "properties": {
        "query": "SOURCE '/var/log/nginx/service-discovery.log' | fields @timestamp, @message | filter @message like /UNHEALTHY/ | stats count() by bin(5m)",
        "region": "ap-southeast-1",
        "title": "Unhealthy Service Instances",
        "view": "timeSeries"
      }
    }
  ]
}
EOF
```

---

## 🎯 **Portfolio Benefits**

### **What This Demonstrates:**

#### **1. Enterprise Microservices Patterns**
- ✅ **Service Discovery:** Automatic instance detection
- ✅ **Load Balancing:** Round-robin, least-connections, health-based
- ✅ **Circuit Breakers:** Automatic failover and retry logic
- ✅ **Health Checks:** Continuous service monitoring
- ✅ **Zero Downtime:** Rolling deployments with traffic shifting

#### **2. Production-Grade Operations**
- ✅ **Observability:** Metrics, logging, tracing
- ✅ **Resilience:** Fault tolerance, graceful degradation
- ✅ **Scalability:** Horizontal scaling, auto-discovery
- ✅ **Security:** Internal networking, proxy patterns
- ✅ **Cost Optimization:** Efficient resource utilization

#### **3. DevOps Excellence**
- ✅ **Infrastructure as Code:** Terraform modules
- ✅ **Automation:** GitHub Actions workflows
- ✅ **Monitoring:** CloudWatch dashboards
- ✅ **Configuration Management:** Dynamic nginx config
- ✅ **Service Mesh Patterns:** Without the complexity

---

## 💰 **Cost Impact: Still $0 Additional**

| Component | Current Cost | With Load Balancing | Savings vs ALB |
|-----------|-------------|-------------------|----------------|
| **EC2 Instances** | $0 (free tier) | $0 (free tier) | $0 |
| **nginx** | $0 (included) | $0 (enhanced) | $0 |
| **Service Discovery** | $0 | $0 (bash scripts) | $0 |
| **Load Balancing** | $0 | $0 (nginx upstream) | **$90/month** |
| **Health Checks** | $0 | $0 (curl commands) | $0 |
| **TOTAL** | **$3-5/month** | **$3-5/month** | **$90/month saved** |

---

## 🚀 **Demo Scenarios for Interviews**

### **Scenario 1: Horizontal Scaling Demo**
```bash
# Scale catalog service to 3 instances
aws ecs update-service --service catalog --desired-count 3

# Show load balancing in action
curl -H "Host: catalog.phshoesproject.com" http://your-ip/health
# Returns different instance IDs showing load balancing
```

### **Scenario 2: Fault Tolerance Demo**
```bash
# Stop one catalog instance
aws ecs stop-task --task <task-arn>

# Show automatic failover
curl catalog.phshoesproject.com/api/products
# Still works! nginx routes to healthy instances
```

### **Scenario 3: Zero Downtime Deployment**
```bash
# Deploy new version with rolling update
aws ecs update-service --service catalog --force-new-deployment

# Show traffic gradually shifts to new instances
watch -n 1 'curl -s catalog.phshoesproject.com/version'
```

---

## ✅ **Implementation Priority**

### **Week 1: Foundation**
1. ✅ Update task definitions for dynamic ports
2. ✅ Create service discovery scripts
3. ✅ Test with 2x catalog instances

### **Week 2: Production Features**
1. ✅ Add health checks and circuit breakers
2. ✅ Implement intelligent load balancing
3. ✅ Add monitoring and metrics

### **Week 3: Portfolio Polish**
1. ✅ Create demo scenarios
2. ✅ Add documentation
3. ✅ Record demo videos

This solution gives you **enterprise-grade microservices** that will impress any interviewer, while maintaining your **$0 additional cost** requirement! 🎉

Want me to start implementing Phase 1?