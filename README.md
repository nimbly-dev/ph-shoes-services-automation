# ph-shoes-services-automation
Automation repository for migrating the PH Shoes services from Render to AWS ECS.

## Terraform core
The `terraform-core/` directory is the entrypoint for provisioning shared AWS
infrastructure. Key files:

- `backend.tf` – stores state in `terraform.tfstate`.
- `providers.tf` – pins Terraform/AWS versions and applies the global tag set via `default_tags`.
- `variables.tf` – input knobs for region, environment, application, project, owner, and extra tags.
- `main.tf` – wires the Resource Group, AppRegistry Application, public ECR repositories, and GitHub OIDC IAM role using the modules under `modules/`.
- `modules/network` + `modules/ecs-cluster` – create the ECS VPC, subnets, cluster, EC2 launch template/ASG, and capacity provider.
- `modules/ecs-service` – reusable ECS service definition (awsvpc/EC2) with inputs for container image, env/secrets, ingress rules, and optional ALB/NLB target groups.
- `modules/frontend-alb` – opinionated internet-facing Application Load Balancer + Route53 alias for the SPA.

Run Terraform from this directory (or from future `environments/<env>` wrappers):

```bash
cd terraform-core
terraform init
terraform plan -var app_name="ph-shoes-services" -var environment="prod"
```

## Tagging standard
All resources inherit these tags automatically:

| Key         | Value                                |
|-------------|--------------------------------------|
| `Project`   | `ph-shoes-services-automation`       |
| `Environment` | `var.environment` (defaults to `prod`) |
| `Application` | `var.app_name`                     |
| `ManagedBy` | `terraform`                          |
| `Owner`     | `nimbly`                             |

Extend or override using `-var extra_tags='{ Team = "platform" }'` when necessary.

## Provisioned resources
- **Project lens** – AWS Resource Group + AppRegistry application keyed by the shared tags.
- **Container registry** – Public ECR repositories for the SPA plus every `*-web` backend module (alerts web/scheduler, catalog, notification, text-search, user-accounts). Override defaults with `frontend_repositories`, `backend_web_modules`, or `additional_ecr_repositories`.
- **CI/CD IAM** – GitHub OIDC provider + federated role (default name `ph-shoes-github-oidc`) preloaded with the `ecr-public:*` permissions required for Docker pushes. Configure allowed repos via `github_owner`, `github_repositories`, and `github_subjects`.
- **Network + ECS cluster** – `modules/network` provisions a dedicated VPC with two public subnets and internet gateway. `modules/ecs-cluster` adds an ECS cluster, EC2 launch template, Auto Scaling Group, capacity provider, and security group for the hosts (defaulting to `t3.micro`, desired capacity `0`). Tune via `vpc_cidr`, `public_subnet_cidrs`, and the `ecs_*` variables.
- **Service template** – `modules/ecs-service` defines a reusable ECS service/task-definition pattern (awsvpc, EC2 launch type, log group, IAM roles, env/secrets inputs, ALB target group optional). `module.frontend_service` uses it when `frontend_enable = true`.
- **Frontend ALB + DNS** – `modules/frontend-alb` (enabled via `frontend_enable`) creates an internet-facing ALB with HTTP→HTTPS redirect, attaches the SPA target group, and creates a Route53 alias (cert ARN + hosted zone ID required).

## Next steps
- Override `frontend_*` variables (image URI, cert ARN, hosted zone ID, desired count, env/secrets) and set `frontend_enable=true` to provision the public SPA service + ALB.
- Wire additional services by creating per-environment entrypoints (e.g., `terraform-core/environments/prod`) that invoke `modules/ecs-service` with their container settings.
- Expand IAM policies for individual services (task roles) as they require access to AWS APIs (e.g., DynamoDB, SES).
- Author GitHub Actions workflows that assume the exported IAM role ARN, push Docker images to the provisioned repos, and deploy/update the ECS services; store per-service `.env` values in GitHub secrets.
