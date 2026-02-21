# PH Shoes Services Automation

Infrastructure automation for PH Shoes web/frontend services on AWS ECS (EC2 launch type).

## Architecture (high level)
- ECS cluster on EC2 ASG (cost-optimized, scale-to-zero supported).
- Services run on ECS tasks; routing via Cloudflare or Route53.
- DNS updates via `auto-dns-update.yml` (Terraform in `terraform-dns/`).
- Deployments via GitHub Actions workflows (OIDC → AWS).

## Architecture Diagram
![PH Shoes Backend Services Architecture](images/ph-shoes-backend-services-architecture.png)

Domain handling (current):
- DNS resolution: Browser queries Cloudflare DNS for `phshoesproject.com`, then receives ECS public IP(s).
- Request routing: Browser request flows through Cloudflare proxy to ECS instance Nginx, then Nginx routes to service containers.

## Structure
- `terraform-core/` - VPC, ECS cluster/ASG, IAM, monitoring.
- `terraform-service-deploy/` - ECS task/service deployment module.
- `terraform-dns/` - DNS automation and service placement discovery.
- `.github/workflows/` - Deploy, DNS, and scale workflows.
- `nginx-services.conf` - Instance-level routing config.

## Workflows
- Core infra: workflow-based plan/apply (no local apply).
- DNS: `auto-dns-update.yml`.
- Service deploy: `deploy-service.yml`, `deploy-all-services.yml`.
- Scale down: `stop-all.yml`.

Example:
```bash
gh workflow run deploy-service.yml -f service=frontend -f image_uri=<ecr_image_uri>
```
