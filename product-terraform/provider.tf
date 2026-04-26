# ─────────────────────────────────────────
# provider.tf
# Tells Terraform which cloud to use
# and which version of AWS plugin
# ─────────────────────────────────────────

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"    # use AWS provider version 5.x
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
  # Credentials come from aws configure
  # Never hardcode credentials here!
}
