# PH Shoes Services Automation

Infrastructure automation for PH Shoes web/frontend services on AWS ECS.

## Structure
- `terraform-core/` - Core AWS infrastructure (ECS, VPC, IAM, monitoring).
- `terraform-dns/` - DNS automation.
- `.github/workflows/` - CI workflows for apply/deploy/stop.
- `nginx-services.conf` - Nginx routing config.

## Apply and Deploy
- `terraform-core`: use the approved workflow-based plan/apply (no local apply).
- `terraform-dns`: `auto-dns-update.yml`.
- Services: `deploy-service.yml`, `deploy-all-services.yml`.
- Stop services: `stop-all.yml`.

Example:
```bash
# Deploy a single service
gh workflow run deploy-service.yml -f service_name=frontend -f image_tag=latest
```
