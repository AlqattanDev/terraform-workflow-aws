# Terraform Workflow AWS

Automated infrastructure provisioning workflow that integrates ServiceNow requests with AWS deployments via GitHub Actions.

## Overview

This project provides a streamlined workflow for:
1. Receiving infrastructure requests (from ServiceNow or manual trigger)
2. Auto-generating Terraform configurations
3. Creating Pull Requests for review
4. Deploying to AWS on merge
5. Tracking request status through folder organization

## Workflow Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   ServiceNow    │───►│  GitHub Actions  │───►│  Pull Request   │
│   Request       │    │  (Process)       │    │  Created        │
└─────────────────┘    └──────────────────┘    └────────┬────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  AWS Resources  │◄───│  Terraform       │◄───│  PR Merged      │
│  Created        │    │  Apply           │    │  (Human Review) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │  Request folder  │
                       │  → deployed/     │
                       │  or failed/      │
                       └──────────────────┘
```

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

## Quick Start

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

Or trigger via GitHub API:

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/AlqattanDev/terraform-workflow-aws/actions/workflows/process-request.yml/dispatches \
  -d '{
    "ref": "main",
    "inputs": {
      "ticket_id": "REQ0012345",
      "resource_type": "s3-bucket",
      "resource_name": "my-app-data",
      "environment": "production",
      "aws_region": "us-east-1",
      "requested_by": "user@example.com"
    }
  }'
```

### 2. Review the PR

The workflow automatically creates a PR with:
- Generated Terraform code in `requests/in-progress/{ticket_id}/`
- Request metadata in `request.json`
- Resource details and tags including ticket ID

### 3. Merge to Deploy

On merge:
- `terraform apply` runs automatically
- Resources are created in AWS
- Request folder moves to `deployed/` or `failed/`
- Outputs are captured in `outputs.json`

## Initial Setup

### Prerequisites

- AWS Account
- GitHub Account with repository access
- Terraform CLI (for initial setup)
- AWS CLI configured with credentials

### 1. Clone and Configure

```bash
git clone https://github.com/AlqattanDev/terraform-workflow-aws.git
cd terraform-workflow-aws
```

### 2. Deploy Hub Infrastructure

```bash
cd infrastructure/hub
terraform init
terraform apply
```

This creates:
- GitHub OIDC provider (reuses existing if present)
- `GitHubActionsExecutor` IAM role
- S3 bucket for Terraform state: `terraform-workflow-state-{account_id}`
- DynamoDB table for state locking: `terraform-state-locks`

### 3. Enable Repository Permissions

Go to Repository Settings → Actions → General → Workflow permissions:
- Enable "Allow GitHub Actions to create and approve pull requests"

## Supported Resources

| Resource Type | Template | Features |
|---------------|----------|----------|
| S3 Bucket | `s3-bucket.tf.tmpl` | Versioning, encryption, public access blocking |
| EC2 Instance | `ec2-instance.tf.tmpl` | Amazon Linux 2023, configurable instance type |

### Resource Parameters

**S3 Bucket:**
- `resource_name` - Bucket name (must be globally unique)
- `versioning_enabled` - Enable versioning (true/false)
- `environment` - Environment tag
- `aws_region` - Target region

**EC2 Instance:**
- `resource_name` - Instance name tag
- `instance_type` - Instance type (default: t3.micro)
- `environment` - Environment tag
- `aws_region` - Target region

## Adding New Resource Types

1. Create template in `templates/` (e.g., `rds-instance.tf.tmpl`)
2. Add resource type to `process-request.yml` workflow inputs
3. Update the template selection logic in the workflow
4. Add any required IAM permissions to `infrastructure/hub/roles.tf`

## Security

- **OIDC Authentication**: No long-lived AWS credentials stored in GitHub
- **State Encryption**: S3 bucket with AES256 server-side encryption
- **State Locking**: DynamoDB prevents concurrent modifications
- **PR Review**: All infrastructure changes require human approval before merge
- **Tagging**: All resources tagged with ticket ID for traceability

## AWS Resources Created by Hub Setup

| Resource | Name | Purpose |
|----------|------|---------|
| IAM Role | `GitHubActionsExecutor` | GitHub Actions assumes this role via OIDC |
| S3 Bucket | `terraform-workflow-state-{account_id}` | Terraform state storage |
| DynamoDB Table | `terraform-state-locks` | State locking |
| OIDC Provider | `token.actions.githubusercontent.com` | GitHub Actions authentication |

## Configuration Reference

| Setting | Location | Description |
|---------|----------|-------------|
| AWS Account ID | Auto-detected | Used in bucket naming |
| GitHub Org/Repo | `infrastructure/hub/roles.tf` | OIDC trust configuration |
| AWS Region | Workflow files + templates | Default: us-east-1 |
| State Bucket | `templates/*.tf.tmpl` | Auto-configured |

## Request Lifecycle

```
pending/          → Request received but not processed
in-progress/      → PR created, awaiting review
deployed/         → Successfully applied to AWS
failed/           → Terraform apply failed
```

Each request folder contains:
- `main.tf` - Generated Terraform configuration
- `request.json` - Request metadata and status
- `outputs.json` - Terraform outputs (after deployment)

## Future Enhancements

- [ ] ServiceNow webhook/polling for automatic request ingestion
- [ ] RDS, Lambda, and VPC templates
- [ ] Cost estimation before deployment
- [ ] Slack/email notifications
- [ ] Destroy workflow for resource decommissioning
- [ ] Approval workflow integration with ServiceNow change requests

## License

MIT
