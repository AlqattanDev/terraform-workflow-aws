# S3 Bucket Template
# Generated for ticket: REQ0000002
# Requested by: ali@example.com
# Created: 2025-12-04T01:52:42Z

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-workflow-state-414483036967"
    key            = "requests/REQ0000002/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project      = "terraform-workflow-aws"
      ManagedBy    = "terraform"
      TicketID     = "REQ0000002"
      RequestedBy  = "ali@example.com"
      Environment  = "development"
    }
  }
}

resource "aws_s3_bucket" "main" {
  bucket = "test-bucket-success-414483036967"

  tags = {
    Name = "test-bucket-success-414483036967"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "true" == "true" ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "ticket_id" {
  description = "ServiceNow ticket ID"
  value       = "REQ0000002"
}
