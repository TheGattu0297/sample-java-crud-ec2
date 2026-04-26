# ─────────────────────────────────────────
# variables.tf
# All configurable values live here
# Change these without touching main.tf!
# ─────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true    # hides value in terraform output
}

variable "key_pair_name" {
  description = "AWS Key Pair name for SSH access to EC2"
  type        = string
}

variable "docker_image" {
  description = "Docker Hub image to deploy"
  type        = string
  default     = "sakethram0222/product-app:latest"
}
