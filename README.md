# PH Shoes Services Automation

Infrastructure automation for PH Shoes microservices on AWS ECS.

## Quick Start

```bash
# Deploy core infrastructure
cd terraform-core && terraform init && terraform apply

# Deploy DNS routing
cd terraform-dns && terraform init && terraform apply

# Deploy services via GitHub Actions workflows
gh workflow run deploy-service.yml -f service_name=frontend -f image_tag=latest
```

## Structure

- `terraform-core/` - Core AWS infrastructure (ECS, VPC, IAM)
- `terraform-dns/` - Smart DNS routing with service placement detection  
- `.github/workflows/` - Deployment automation
- `nginx-services.conf` - Nginx configuration for service routing

## Services

- Frontend SPA (React)
- User Accounts API
- Catalog API  
- Alerts API
- Text Search API

All services auto-scale to zero for cost optimization.
