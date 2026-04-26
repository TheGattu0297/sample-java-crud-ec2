# ─────────────────────────────────────────
# outputs.tf
# Values printed after terraform apply
# So you know where your app is running!
# ─────────────────────────────────────────

output "ec2_public_ip" {
  description = "Public IP of your EC2 instance"
  value       = aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of your EC2 instance"
  value       = aws_instance.app.public_dns
}

output "app_url" {
  description = "URL to access your Spring Boot app"
  value       = "http://${aws_instance.app.public_ip}:8080/api/products"
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "ssh_command" {
  description = "Command to SSH into your EC2 instance"
  value       = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.app.public_ip}"
}


