# 🚀 Spring Boot CRUD API — AWS EC2 Deployment

A production-style REST API built with Spring Boot and deployed on AWS using Docker and Terraform.

---

## 📌 Overview

This project demonstrates end-to-end deployment of a Dockerized Java application on AWS infrastructure provisioned with Terraform. Credentials are managed securely via AWS Secrets Manager — no passwords hardcoded anywhere.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 21 |
| Framework | Spring Boot 3 |
| Database | PostgreSQL (AWS RDS) |
| ORM | Hibernate / JPA |
| Containerization | Docker (multi-stage build) |
| Registry | Docker Hub |
| Infrastructure | Terraform |
| Compute | AWS EC2 (t2.micro) |
| Secrets | AWS Secrets Manager |
| Networking | AWS VPC, Subnets, Security Groups |
| Auth | AWS IAM Roles (least privilege) |

---

## 📁 Project Structure

```
sample-java-crud-ec2/
├── SampleJava/                   # Spring Boot Application
│   ├── src/
│   │   └── main/java/com/learn/productcrud/
│   │       ├── controller/       # REST Controllers
│   │       ├── service/          # Business Logic
│   │       ├── repository/       # JPA Repositories
│   │       ├── model/            # Entity Classes
│   │       ├── dto/              # Data Transfer Objects
│   │       └── exception/        # Custom Exceptions
│   ├── Dockerfile                # Multi-stage Docker build
│   ├── docker-compose.yml        # Local development setup
│   └── pom.xml
│
└── product-terraform/            # AWS Infrastructure (IaC)
    ├── main.tf                   # VPC, EC2, RDS, IAM, Secrets
    ├── variables.tf              # Input variables
    ├── outputs.tf                # Output values (IP, endpoint)
    └── provider.tf               # AWS provider config
```

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/products` | Get all products |
| `GET` | `/api/products/{id}` | Get product by ID |
| `POST` | `/api/products` | Create a product |
| `PUT` | `/api/products/{id}` | Update a product |
| `DELETE` | `/api/products/{id}` | Delete a product |

### Sample Request

```bash
curl -X POST http://<ec2-ip>:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 15",
    "description": "Latest Apple smartphone",
    "price": 1099.99,
    "quantity": 5
  }'
```

---

## 🏃 Run Locally

### Prerequisites
- Docker Desktop
- Java 21
- Maven

```bash
cd SampleJava
docker compose up --build
```

API available at: `http://localhost:8080/api/products`

---

## ☁️ Deploy to AWS

### Prerequisites
- AWS CLI configured
- Terraform installed
- Docker Hub account

### Steps

**1. Build & push Docker image**
```bash
cd SampleJava
docker buildx build \
  --platform linux/amd64 \
  -t <dockerhub-username>/product-app:latest \
  --push .
```

**2. Deploy infrastructure**
```bash
cd product-terraform
terraform init
terraform apply
```

Terraform will prompt for:
- `db_username` — RDS database username
- `db_password` — RDS database password (stored in Secrets Manager)

**3. Get outputs**
```bash
terraform output
# ec2_public_ip = "x.x.x.x"
# rds_endpoint  = "xxx.rds.amazonaws.com:5432"
# app_url       = "http://x.x.x.x:8080/api/products"
```

---

## 🏗️ AWS Architecture

```
Internet
    │
    ▼
EC2 (t2.micro)  ──────────────────────►  RDS PostgreSQL
  - Docker                                (private subnet)
  - Spring Boot App
    │
    ▼
AWS Secrets Manager
  (DB credentials fetched at runtime)
```

### Security
- RDS is in a **private subnet** — not accessible from the internet
- EC2 connects to RDS via **Security Group rules** only
- DB credentials stored in **AWS Secrets Manager**
- EC2 uses **IAM Role** to fetch secrets — no hardcoded passwords

---

## 🧹 Destroy Infrastructure

```bash
cd product-terraform
terraform destroy
```

> ⚠️ This will delete all AWS resources including the RDS database and its data.

---

## 📝 License

MIT
