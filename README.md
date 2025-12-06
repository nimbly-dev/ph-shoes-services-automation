# ph-shoes-services-automation
Automation repository for migrating the PH Shoes services from Render to AWS ECS.

## Terraform core
The `terraform-core/` directory is the entrypoint for provisioning shared AWS
infrastructure. Key files:

- `backend.tf` – stores state in `terraform.tfstate`.
- `providers.tf` – pins Terraform/AWS versions and applies the global tag set via `default_tags`.
- `variables.tf` – input knobs for region, environment, application, project, owner, and extra tags.
- `main.tf` – wires the Resource Group, AppRegistry Application, public ECR repositories, and GitHub OIDC IAM role using the modules under `modules/`.

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

## Next steps
- Add Terraform modules for ECS cluster/capacity providers and deployment-time IAM policies, then attach them to the AppRegistry application via tags.
- Create per-environment entrypoints (e.g., `terraform-core/environments/prod`) when you need isolated state per env.
- Author GitHub Actions workflows that assume the exported IAM role ARN and push images to the provisioned repositories; store per-service `.env` values in GitHub secrets.
