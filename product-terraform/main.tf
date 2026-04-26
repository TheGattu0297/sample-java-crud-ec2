# ─────────────────────────────────────────
# main.tf
# ─────────────────────────────────────────

# ── VPC ─────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "product-vpc" }
}

# ── INTERNET GATEWAY ─────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "product-igw" }
}

# ── SUBNETS ──────────────────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "product-public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "product-private-subnet" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = { Name = "product-private-subnet-2" }
}

# ── ROUTE TABLE ──────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "product-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── SECRETS MANAGER ──────────────────────
# Stores DB credentials securely
# EC2 fetches at runtime — password never in any file!
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "product/db-credentials"
  recovery_window_in_days = 0  # instant delete (use 7-30 in production)
  tags = { Name = "product-db-credentials" }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password  # comes from TF_VAR_db_password env variable
  })
}

# ── IAM ROLE FOR EC2 ─────────────────────
# Gives EC2 an identity to talk to AWS services
resource "aws_iam_role" "ec2_role" {
  name = "product-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "product-ec2-role" }
}

# ── IAM POLICY ───────────────────────────
# Least privilege: EC2 can ONLY read THIS specific secret
resource "aws_iam_role_policy" "secrets_policy" {
  name = "product-secrets-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_secretsmanager_secret.db_credentials.arn]
    }]
  })
}

# ── IAM INSTANCE PROFILE ─────────────────
# Wrapper that attaches IAM role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "product-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ── SECURITY GROUP: EC2 ──────────────────
resource "aws_security_group" "ec2" {
  name        = "product-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Spring Boot app"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = { Name = "product-ec2-sg" }
}

# ── SECURITY GROUP: RDS ──────────────────
resource "aws_security_group" "rds" {
  name        = "product-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    description     = "PostgreSQL from EC2 only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "product-rds-sg" }
}

# ── RDS SUBNET GROUP ─────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "product-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]
  tags       = { Name = "product-db-subnet-group" }
}

# ── RDS INSTANCE ─────────────────────────
resource "aws_db_instance" "postgres" {
  identifier        = "product-db"
  engine            = "postgres"
  engine_version    = "16.6"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "productdb"
  username = var.db_username
  password = var.db_password  # RDS needs this at creation time

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = { Name = "product-db" }
}

# ── EC2 INSTANCE ─────────────────────────
resource "aws_instance" "app" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name  # ← EC2 gets permission!

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y

    # Install Docker + AWS CLI
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # ── FETCH CREDENTIALS FROM SECRETS MANAGER ──
    # EC2 uses IAM role to authenticate — no password in script! ✅
    SECRET=$(aws secretsmanager get-secret-value \
      --secret-id product/db-credentials \
      --region us-east-1 \
      --query SecretString \
      --output text)

    # Extract values from JSON
    DB_USERNAME=$(echo $SECRET | python3 -c "import sys,json; print(json.load(sys.stdin)['username'])")
    DB_PASSWORD=$(echo $SECRET | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")

    # Pull correct platform image ✅ (fixes ARM vs AMD64!)
    docker pull --platform linux/amd64 ${var.docker_image}

    # Run app — credentials fetched from Secrets Manager at runtime!
    docker run -d \
      --name product-app \
      --restart always \
      -p 8080:8080 \
      -e DB_URL=jdbc:postgresql://${aws_db_instance.postgres.endpoint}/productdb \
      -e DB_USERNAME=$DB_USERNAME \
      -e DB_PASSWORD=$DB_PASSWORD \
      ${var.docker_image}
  EOF

  tags = { Name = "product-app-ec2" }
}