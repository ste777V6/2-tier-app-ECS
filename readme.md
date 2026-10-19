# Infrastructure (Terraform)

AWS infrastructure for the 3-tier student-portal app (ALB → ECS Fargate → RDS PostgreSQL), organised as **local Terraform modules**.

The root directory wires the modules together. Each area has its own root file (`networking.tf`, `alb.tf`, …) that calls one module.

> Environments (dev / staging / prod) are not split yet. There is one root configuration and one state. See [Adding environments later](#adding-environments-later).

---

## Directory structure

```
Infra/
├── README.md
├── backend.tf           # S3 remote state
├── provider.tf          # terraform{} block, provider "aws", default_tags
├── locals.tf            # Shared name prefix
├── variables.tf         # Root inputs
├── terraform.tfvars     # Values for root inputs
├── outputs.tf           # Root outputs (re-exported from modules)
│
├── networking.tf        # module "networking"
├── security.tf          # module "security"
├── alb.tf               # module "alb"
├── database.tf          # module "database"
├── ecs.tf               # module "ecs"
│
├── snyk_test_infra.tf   # Commented-out insecure resources for Snyk scan tests
│
└── modules/
    ├── networking/      # VPC, subnets, IGW, NAT, route tables
    ├── security/        # ALB / ECS / RDS security groups
    ├── alb/             # ALB, listeners, blue/green target groups, ACM cert, log bucket
    ├── database/        # RDS PostgreSQL, password, DB_LINK secret
    └── ecs/             # ECR, cluster, task definition, service, autoscaling, logs, ECS IAM
```

Each module has the same four files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.

### What goes where

| File | Contains | Never contains |
|---|---|---|
| Root `<area>.tf` | The `module` block for that area | `resource` blocks |
| Root `provider.tf` | `provider "aws"`, `default_tags`, version pins | — |
| Root `backend.tf` | `backend "s3"` config | — |
| `modules/*/main.tf` | `resource`, `data`, `locals` | `provider` or `backend` blocks |
| `modules/*/variables.tf` | Typed, described inputs | Hardcoded environment values |
| `modules/*/outputs.tf` | Values other modules or the root need | Everything "just in case" |
| `modules/*/versions.tf` | `required_providers` with a **minimum** version | Exact pins |

---

## How the modules connect

```
                  networking
                 /    |     \
         vpc_id /     |      \ subnet IDs
               v      |       \
           security   |        \
          /   |   \   |         \
   alb_sg/ ecs_sg  rds_sg        \
        v     |      v            v
       alb    |   database ──────────┐
        \     |                      │ secret_arn
         \    v                      v
          ───► ecs ◄─────────────────┘
   target group ARN,
   autoscaling label
```

Data flows **one way**, top to bottom. No module needs a value from a module below it, so there are no circular dependencies.

Rules:

1. **Data flows from a module's output, through the root, into another module's input.** Modules never reference each other directly.
2. **Modules don't know which environment they run in.** Everything environment-specific comes in through variables.
3. Terraform loads every `.tf` file in the root as one configuration, so `ecs.tf` can use `module.alb` from `alb.tf`. File order doesn't matter.

### Example

```hcl
# ecs.tf (root)
module "ecs" {
  source = "./modules/ecs"

  name               = local.name
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.security.ecs_sg_id]
  target_group_arn   = module.alb.blue_target_group_arn
  secrets            = { DB_LINK = module.database.secret_arn }
  # ...
}
```

---

## Usage

```bash
terraform init        # first time, and whenever a module is added or its source changes
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

### First deployment: certificate validation

The certificate is validated through an **external DNS provider** (freedomain.one), so the first `apply` pauses at `aws_acm_certificate_validation` for up to 45 minutes.

1. Run `terraform apply`. When it starts waiting on the certificate, open a second terminal.
2. Run `terraform output acm_validation_cname_name` and `terraform output acm_validation_cname_value`. These values are known as soon as the certificate resource exists. If they aren't available yet, read them from the ACM console.
3. Create that CNAME record at the DNS provider. The apply continues once AWS validates it.
4. Afterwards, create a CNAME `<app_name>.<domain_name>` → `terraform output load_balancer_dns_name`.

### Useful commands

```bash
terraform plan -target=module.alb    # plan a single module (for development only)
terraform state list module.ecs      # what a module created
terraform output                     # all root outputs
```

---

## Modules

### `networking`

VPC with public and private subnets across the given AZs, an internet gateway and optional NAT gateway(s).

| Input | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name prefix |
| `vpc_cidr` | `string` | — | VPC CIDR (validated) |
| `availability_zones` | `list(string)` | — | At least 2 AZs |
| `public_subnet_cidrs` | `list(string)` | — | One per AZ, same order |
| `private_subnet_cidrs` | `list(string)` | — | One per AZ, same order |
| `enable_nat_gateway` | `bool` | `true` | Create NAT gateway(s) and private default routes |
| `need_single_nat_gateway` | `bool` | `true` | `true` = one NAT in the first AZ, `false` = one NAT per AZ |

**Outputs:** `vpc_id`, `vpc_cidr`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_public_ips`

Subnets, NATs and EIPs use `for_each` keyed by AZ name. Each private subnet has its own route table that points to the NAT in its AZ, or to the single NAT.

### `security`

The three security groups, chained as internet → ALB → ECS → RDS.

| Input | Type | Default |
|---|---|---|
| `name` | `string` | — |
| `vpc_id` | `string` | — |
| `vpc_cidr` | `string` | — |
| `app_port` | `number` | `5000` |
| `db_port` | `number` | `5432` |

**Outputs:** `alb_sg_id`, `ecs_sg_id`, `rds_sg_id`

These groups live in one module because each references the one before it. If every group lived in its owner module, `ecs` and `database` would need values from each other in both directions.

### `alb`

Public ALB with HTTP→HTTPS redirect, blue/green target groups, the ACM certificate and an S3 access-log bucket.

| Input | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Max 23 characters (AWS limits ALB/TG names to 32) |
| `vpc_id` | `string` | — | |
| `public_subnet_ids` | `list(string)` | — | |
| `security_group_id` | `string` | — | |
| `certificate_domain` | `string` | — | FQDN for the certificate |
| `log_bucket_name` | `string` | — | Globally unique |
| `log_prefix` | `string` | `"alb"` | |
| `app_port` | `number` | `5000` | |
| `health_check_path` | `string` | `"/"` | |
| `ssl_policy` | `string` | TLS 1.3/1.2 policy | |
| `certificate_validation_timeout` | `string` | `"45m"` | |
| `enable_deletion_protection` | `bool` | `false` | Turn on for production |

**Outputs:** `alb_arn`, `alb_dns_name`, `alb_zone_id`, `https_listener_arn`, `blue_target_group_arn`, `target_group_arns`, `target_group_names`, `blue_target_group_resource_label`, `acm_validation_cname_name`, `acm_validation_cname_value`, `log_bucket_name`

`blue_target_group_arn` has `depends_on = [aws_lb_listener.https]`. That way, the ECS service only registers tasks once the target group is attached to the ALB.

### `database`

PostgreSQL on RDS, with a Terraform-generated password and a Secrets Manager secret holding the full `DB_LINK` connection string.

| Input | Type | Default |
|---|---|---|
| `name` | `string` | — |
| `subnet_ids` | `list(string)` | — |
| `security_group_ids` | `list(string)` | — |
| `engine_version` | `string` | `"16"` |
| `instance_class` | `string` | `"db.t3.micro"` |
| `allocated_storage` | `number` | `20` |
| `port` | `number` | `5432` |
| `db_name` | `string` | `"mydb"` |
| `username` | `string` | `"myuser"` |
| `multi_az` | `bool` | `false` |
| `skip_final_snapshot` | `bool` | `true` |
| `secret_recovery_window_in_days` | `number` | `0` |

**Outputs:** `secret_arn`, `address`, `port`, `identifier`

### `ecs`

The application tier: ECR repository, Fargate cluster, task definition, service, CPU/memory/request-count autoscaling, the CloudWatch log group, and the IAM permissions used only by ECS.

| Input | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Prefix for cluster, service, ECR, IAM, logs |
| `container_name` | `string` | — | Also the task definition family |
| `image` | `string` | — | Initial image |
| `subnet_ids` | `list(string)` | — | Private subnets |
| `security_group_ids` | `list(string)` | — | |
| `target_group_arn` | `string` | — | |
| `alb_resource_label` | `string` | — | For request-count scaling |
| `secrets` | `map(string)` | `{}` | Env var name → Secrets Manager ARN |
| `environment` | `map(string)` | `{}` | Plain env vars |
| `container_port` | `number` | `5000` | |
| `cpu` / `memory` | `number` | `256` / `512` | |
| `desired_count` | `number` | `2` | Initial count only |
| `autoscaling_min` / `autoscaling_max` | `number` | `2` / `4` | |
| `cpu_target` / `memory_target` | `number` | `70` / `70` | % |
| `requests_per_target` | `number` | `1000` | |
| `execution_role_name` | `string` | `"ecsTaskExecutionRole"` | Existing role, looked up |
| `log_retention_days` | `number` | `7` | |
| `enable_container_insights` | `bool` | `false` | |

**Outputs:** `cluster_name`, `service_name`, `task_definition_family`, `container_name`, `ecr_repository_url`, `log_group_name`, `execution_role_arn`, `task_role_arn`

Notes:
- The task definition ignores changes to `container_definitions`, because the pipeline registers new revisions.
- The service ignores changes to `desired_count`, because autoscaling owns the task count after the first apply.
- Secrets access is granted through an IAM policy on the execution role, built from the `secrets` map.

---

## Adding a new module

1. `mkdir -p modules/<name>` and create `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
2. Copy `versions.tf` from an existing module.
3. Write the resources. Replace hardcoded values with variables.
4. Add **only** the outputs that other modules or the root need.
5. Create a root file `<name>.tf` with the `module` block, wired to other modules' outputs.
6. Run `terraform init && terraform validate && terraform plan`.
7. Document the module's inputs and outputs here.

**Before creating a module, ask whether it is a cohesive unit.** If its resources are only used by one existing module (as the ACM certificate and log bucket are for the ALB), put them in that module instead.

---

## Conventions

- **Every variable has a `type` and a `description`.** Add `validation` where values have rules.
- **Group by purpose, not by resource type.** There's no `iam`, `s3` or `acm` module: those resources live with what uses them.
- **Data flows one way between modules.** If two modules need each other's values, the boundary is wrong.
- **Tags:** common tags come from `default_tags` in `provider.tf`. Modules only set `Name`.
- **No hardcoded regions, account IDs or environment names in modules.** Use variables or data sources.
- **`for_each` over `count`** for collections. Use `count` only for on/off toggles.

---

## Adding environments later

The modules stay unchanged. Add one root per environment, each with its own backend key and tfvars:

```
Infra/
├── modules/            # unchanged
└── envs/
    ├── dev/
    │   ├── networking.tf   # source = "../../modules/networking"
    │   ├── security.tf
    │   ├── alb.tf
    │   ├── database.tf
    │   ├── ecs.tf
    │   ├── backend.tf      # key = "dev/terraform.tfstate"
    │   └── terraform.tfvars
    └── prod/
        └── ...
```
