# IAM Role for GitHub Actions to execute Terraform
# This role can be assumed by GitHub Actions via OIDC

locals {
  github_org  = "AlqattanDev"
  github_repo = "terraform-workflow-aws"
}

# Trust policy allowing GitHub Actions to assume this role
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_org}/${local.github_repo}:*"]
    }
  }
}

# The role GitHub Actions will assume
resource "aws_iam_role" "github_actions_executor" {
  name               = "GitHubActionsExecutor"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name = "github-actions-executor"
  }
}

# Policy for Terraform state management
data "aws_iam_policy_document" "terraform_state_access" {
  # S3 state bucket access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
  }

  # DynamoDB state lock access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.terraform_locks.arn]
  }
}

resource "aws_iam_role_policy" "terraform_state_access" {
  name   = "TerraformStateAccess"
  role   = aws_iam_role.github_actions_executor.id
  policy = data.aws_iam_policy_document.terraform_state_access.json
}

# Policy for provisioning AWS resources (simplified for common resources)
data "aws_iam_policy_document" "terraform_provisioning" {
  # S3 bucket management
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketAcl",
      "s3:PutBucketCORS",
      "s3:PutBucketLogging",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketWebsite",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutReplicationConfiguration",
      "s3:DeleteObject",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketOwnershipControls",
      "s3:PutBucketOwnershipControls",
      "s3:GetAccelerateConfiguration",
      "s3:PutAccelerateConfiguration"
    ]
    resources = ["*"]
  }

  # EC2 management
  statement {
    effect = "Allow"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }

  # RDS management
  statement {
    effect = "Allow"
    actions = [
      "rds:*"
    ]
    resources = ["*"]
  }

  # Lambda management
  statement {
    effect = "Allow"
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }

  # IAM for service roles
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListInstanceProfilesForRole"
    ]
    resources = ["*"]
  }

  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  # Secrets Manager
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecret"
    ]
    resources = ["*"]
  }

  # Tags
  statement {
    effect = "Allow"
    actions = [
      "tag:GetResources",
      "tag:TagResources",
      "tag:UntagResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "terraform_provisioning" {
  name   = "TerraformProvisioning"
  role   = aws_iam_role.github_actions_executor.id
  policy = data.aws_iam_policy_document.terraform_provisioning.json
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions executor role"
  value       = aws_iam_role.github_actions_executor.arn
}
