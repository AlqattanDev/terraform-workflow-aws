# EC2 Instance Template
# Generated for ticket: REQ8928511-retry
# Requested by: ali.alqattan@bank-abc.com
# Created: 2025-12-04T02:21:00Z

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
    key            = "requests/REQ8928511-retry/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Project      = "terraform-workflow-aws"
      ManagedBy    = "terraform"
      TicketID     = "REQ8928511-retry"
      RequestedBy  = "ali.alqattan@bank-abc.com"
      Environment  = "production"
    }
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for the instance
resource "aws_security_group" "main" {
  name        = "tmsx-app-sg"
  description = "Security group for tmsx-app"
  vpc_id      = data.aws_vpc.default.id

  # SSH access (customize as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "tmsx-app-sg"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.main.id]

  # Root volume with customizable size
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "tmsx-app-root"
    }
  }

  # Enable detailed monitoring if production
  monitoring = "production" == "production" ? true : false

  # User data script for initial setup
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo "Instance provisioned for ticket REQ8928511-retry" > /var/log/provision.log
  EOF

  tags = {
    Name = "tmsx-app"
  }
}

# Outputs
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the created EC2 instance"
  value       = aws_instance.main.private_ip
}

output "instance_type" {
  description = "Instance type"
  value       = aws_instance.main.instance_type
}

output "storage_size_gb" {
  description = "Root volume size in GB"
  value       = 30
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.main.id
}

output "ticket_id" {
  description = "ServiceNow ticket ID"
  value       = "REQ8928511-retry"
}
