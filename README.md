# Terraform Workflow AWS

Automated infrastructure provisioning workflow that integrates ServiceNow requests with AWS deployments via GitHub Actions.

## Overview

This project provides a streamlined workflow for:
1. Receiving infrastructure requests (from ServiceNow or manual trigger)
2. Auto-generating Terraform configurations
3. Creating Pull Requests for review
4. Deploying to AWS on merge
5. Tracking request status through folder organization

## Folder Structure

```
terraform-workflow-aws/
├── .github/workflows/          # GitHub Actions workflows
│   ├── process-request.yml     # Generates Terraform from request
│   ├── terraform-plan.yml      # Runs plan on PR
│   └── terraform-apply.yml     # Applies on merge, moves folders
├── infrastructure/             # Core infrastructure setup
│   ├── hub/                    # OIDC, IAM roles, state backend
│   └── spoke/                  # Target account configuration
├── requests/                   # Request tracking
│   ├── pending/                # New requests
│   ├── in-progress/            # PRs created, awaiting review
│   ├── deployed/               # Successfully applied
│   └── failed/                 # Failed deployments
└── templates/                  # Terraform templates
    ├── s3-bucket.tf.tmpl
    └── ec2-instance.tf.tmpl
```

## Workflow

```
ServiceNow Request → GitHub Dispatch → Generate TF → Create PR → Review → Merge → Apply → Move to deployed/failed
```

### 1. Trigger a Request

Via GitHub Actions UI or API:

```bash
gh workflow run process-request.yml \
  -f ticket_id=REQ0012345 \
  -f resource_type=s3-bucket \
  -f resource_name=my-app-data \
  -f environment=production \
  -f aws_region=us-east-1 \
  -f requested_by=user@example.com
```

### 2. Review the PR

The workflow automatically creates a PR with:
- Generated Terraform code
- Request metadata
- Terraform plan output (as comment)

### 3. Merge to Deploy

On merge:
- `terraform apply` runs automatically
- Request folder moves to `deployed/` or `failed/`
- Outputs are captured in `request.json`

## Initial Setup

### 1. Deploy Hub Infrastructure

```bash
cd infrastructure/hub
terraform init
terraform apply
```

This creates:
- GitHub OIDC provider
- GitHubActionsExecutor IAM role
- S3 bucket for Terraform state
- DynamoDB table for state locking

### 2. Create GitHub Repository

```bash
gh repo create terraform-workflow-aws --public --source=. --push
```

### 3. Enable Workflows

Workflows are triggered automatically once the repository is created.

## Supported Resources

- **S3 Bucket**: With versioning, encryption, public access blocking
- **EC2 Instance**: Amazon Linux 2023, configurable instance type

## Adding New Resource Types

1. Create template in `templates/` (e.g., `rds-instance.tf.tmpl`)
2. Add resource type to `process-request.yml` workflow inputs
3. Update the template selection logic in the workflow

## Security

- **OIDC Authentication**: No long-lived credentials stored
- **State Encryption**: S3 bucket with AES256 encryption
- **State Locking**: DynamoDB prevents concurrent modifications
- **PR Review**: All changes require human approval

## Configuration

| Setting | Location | Description |
|---------|----------|-------------|
| AWS Account ID | `infrastructure/hub/roles.tf` | Target AWS account |
| GitHub Org/Repo | `infrastructure/hub/roles.tf` | OIDC trust configuration |
| AWS Region | Workflow files | Default deployment region |
| State Bucket | `templates/*.tf.tmpl` | Terraform backend config |
