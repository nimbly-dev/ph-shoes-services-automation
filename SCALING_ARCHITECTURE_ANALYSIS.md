# Scaling Architecture Analysis: Multiple Service Instances

## 🎯 **Current Architecture: Single Instance Design**

Your current architecture is optimized for **1 instance per service** with these characteristics:

### **Current Service Mapping:**
```
catalog.phshoesproject.com → EC2 Instance → nginx:80 → localhost:8083 → Single Catalog Container
```

---

## 🔍 **What Happens with 2x Catalog Services**

### **Scenario 1: Both Tasks on Same EC2 Instance**
```
ECS Scheduler Decision: Place both catalog tasks on same instance
┌─────────────────────────────────────────────────────────────┐
│                    EC2 Instance (t3.micro)                  │
├─────────────────────────────────────────────────────────────┤
│ nginx:80 → localhost:8083                                   │
├─────────────────────────────────────────────────────────────┤
│ Catalog Task 1: Container Port 8080 → Host Port 8083 ✅    │
│ Catalog Task 2: Container Port 8080 → Host Port ???? ❌    │
└─────────────────────────────────────────────────────────────┘
```

**Problem:** Port conflict! Both tasks want host port 8083.

### **Scenario 2: Tasks on Different EC2 Instances**
```
Instance 1:                          Instance 2:
┌─────────────────────────────────┐  ┌─────────────────────────────────┐
│ Catalog Task 1: Port 8083 ✅   │  │ Catalog Task 2: Port 8083 ✅   │
└─────────────────────────────────┘  └─────────────────────────────────┘
                    ▲                                  ▲
                    │                                  │
            catalog.phshoesproject.com ──────────────────
                    │
            Dynamic DNS picks ONE instance ❌
```

**Problem:** DNS routes to only one instance, other instance unreachable.

---

## 🚨 **Current Architecture Limitations**

### **1. Port Mapping Conflicts**
```hcl
# Current task definition (simplified)
port_mappings = [
  {
    container_port = 8080
    host_port      = 8083  # Fixed port - causes conflicts
    protocol       = "tcp"
  }
]
```

### **2. DNS Single-Point Routing**
```bash
# Dynamic DNS script (from modules/dynamic-dns/main.tf)
TASK_ARN=$(aws ecs list-tasks \
  --service-name $SERVICE_NAME \
  --query 'taskArns[0]' \    # Only gets FIRST task ❌
  --output text)
```

### **3. Nginx Static Configuration**
```nginx
# nginx-services.conf
server {
    listen 80;
    server_name catalog.phshoesproject.com;
    
    location / {
        proxy_pass http://localhost:8083;  # Single port ❌
    }
}
```

---

## 🛠️ **Solutions for Multiple Service Instances**

### **Option 1: Dynamic Port Allocation (Recommended)**

#### **A. Update Task Definition**
```hcl
port_mappings = [
  {
    container_port = 8080
    host_port      = 0      # Dynamic port allocation ✅
    protocol       = "tcp"
  }
]
```

#### **B. Use Application Load Balancer**
```hcl
resource "aws_lb" "catalog" {
  name               = "catalog-alb"
  internal           = false
  load_balancer_type = "application"
  
  # Cost: ~$18/month per ALB ❌
}

resource "aws_lb_target_group" "catalog" {
  name     = "catalog-targets"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path = "/actuator/health"
  }
}
```

**Pros:** ✅ True load balancing, health checks, auto-discovery
**Cons:** ❌ $18/month per service, breaks cost optimization

#### **C. Service Discovery + nginx upstream**
```nginx
upstream catalog_backend {
    # Dynamically populated by service discovery
    server 10.0.1.100:32768;  # Dynamic port from ECS
    server 10.0.1.101:32769;  # Dynamic port from ECS
}

server {
    listen 80;
    server_name catalog.phshoesproject.com;
    
    location / {
        proxy_pass http://catalog_backend;
    }
}
```

### **Option 2: Multiple Fixed Ports**

#### **A. Reserve Port Ranges**
```hcl
# Catalog service ports: 8083, 8086, 8089
# Alerts service ports: 8084, 8087, 8090
# etc.
```

#### **B. Update nginx with multiple upstreams**
```nginx
upstream catalog_backend {
    server localhost:8083;
    server localhost:8086;
    server localhost:8089;
}
```

### **Option 3: Container-Level Load Balancing**

#### **A. Use nginx as load balancer inside container**
```dockerfile
# Inside catalog service container
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
# nginx routes to multiple Spring Boot instances within container
```

---

## 💰 **Cost Impact Analysis**

### **Current Architecture (1 instance per service):**
- **Cost:** ~$3-5/month
- **Scaling:** Manual, workflow-triggered
- **Load Balancing:** None (single instance)

### **Option 1: ALB per Service**
- **Cost:** ~$90/month (5 services × $18/month)
- **Scaling:** Automatic
- **Load Balancing:** AWS-managed

### **Option 2: nginx + Service Discovery**
- **Cost:** ~$3-5/month (same as current)
- **Scaling:** Manual + service discovery
- **Load Balancing:** nginx-based

### **Option 3: Horizontal Pod Autoscaler (HPA) Style**
- **Cost:** ~$3-5/month
- **Scaling:** Custom metrics-based
- **Load Balancing:** ECS service-level

---

## 🎯 **Recommended Approach for Your Use Case**

### **For Cost-Optimized Scaling:**

#### **Phase 1: Enhanced Single Instance (Current)**
- Keep 1 instance per service
- Optimize resource allocation
- Use ECS service auto-scaling based on CPU/memory

#### **Phase 2: nginx + Service Discovery**
```bash
# Scale specific service
aws ecs update-service --service catalog --desired-count 2

# Update nginx config dynamically
./scripts/update-nginx-upstreams.sh catalog
```

#### **Phase 3: Container-Level Scaling**
```yaml
# docker-compose style within single container
services:
  catalog-1:
    image: catalog:latest
    ports: ["8080"]
  catalog-2:
    image: catalog:latest
    ports: ["8081"]
  nginx:
    image: nginx
    ports: ["80:80"]
    depends_on: [catalog-1, catalog-2]
```

---

## 🔧 **Implementation Steps**

### **Step 1: Test Current Scaling**
```bash
# Scale catalog to 2 instances
aws ecs update-service \
  --cluster ph-shoes-services-ecs \
  --service ph-shoes-services-automation-catalog \
  --desired-count 2

# Check task placement
aws ecs list-tasks \
  --cluster ph-shoes-services-ecs \
  --service-name ph-shoes-services-automation-catalog
```

### **Step 2: Monitor Behavior**
- Check CloudWatch dashboards
- Verify DNS routing
- Test service availability

### **Step 3: Implement Solution**
Based on test results, implement one of the solutions above.

---

## 📊 **Current vs Scaled Architecture**

| Aspect | Current (1x) | Scaled (2x) with ALB | Scaled (2x) with nginx |
|--------|-------------|---------------------|----------------------|
| **Cost** | $3-5/month | $90+/month | $3-5/month |
| **Complexity** | Low | Medium | High |
| **Reliability** | Single point of failure | High availability | Medium availability |
| **Scaling** | Manual | Automatic | Manual + scripted |
| **Load Balancing** | None | AWS ALB | nginx upstream |

---

## ✅ **Immediate Action Items**

1. **Test current scaling behavior:**
   ```bash
   aws ecs update-service --service catalog --desired-count 2
   ```

2. **Monitor task placement and port conflicts**

3. **Decide on scaling strategy based on:**
   - Traffic patterns
   - Cost constraints
   - Reliability requirements

4. **Implement chosen solution incrementally**

Your current architecture is **excellent for single-instance services** but needs enhancement for true horizontal scaling. The nginx + service discovery approach maintains your cost optimization while enabling scaling.