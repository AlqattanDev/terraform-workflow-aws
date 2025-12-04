# GitHub OIDC Identity Provider
# This allows GitHub Actions to authenticate with AWS without long-lived credentials

data "aws_caller_identity" "current" {}

# Use existing OIDC provider if it already exists, otherwise create one
data "aws_iam_openid_connect_provider" "github_existing" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  oidc_provider_arn = data.aws_iam_openid_connect_provider.github_existing.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = local.oidc_provider_arn
}
