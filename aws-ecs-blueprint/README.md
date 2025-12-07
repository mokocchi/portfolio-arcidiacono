# AWS ECS Platform Blueprint (ECS on EC2 + ALB + RDS + Automated Backups)

This repository provides a clean, production-inspired blueprint for deploying web applications on AWS using ECS on EC2.  
It is based on real-world architectural patterns but has been fully generalized and modernized for public use.

The goal is to offer a reproducible, modular, and educational reference for engineers who want to understand how compute, networking, observability, databases, security, and automation fit together in a real AWS platform.

---

## 🌐 Architecture Overview

### **Core components**
- **VPC** with public subnets (ALB/ECS) and private subnets (RDS)
- **Application Load Balancer (ALB)** for routing HTTP traffic
- **ECS Cluster (EC2 launch type)** with:
  - Auto Scaling Group (ASG)
  - Capacity Provider integration
  - Instance bootstrap via user data + SSM agent
- **Task Definition** with multi-container architecture:
  - Backend application container
  - Reverse proxy container (e.g., NGINX)
- **RDS PostgreSQL** deployed in private subnets with restricted access
- **AWS Secrets Manager** for database credentials / connection string
- **CloudWatch Logs** for centralized application logging
- **Terraform IaC**, fully modular and reproducible

### **Optional extension: Automated RDS Backups**
Located under `extras/backups/`:
- Private S3 bucket for secure backup storage
- Lambda function deployed inside the VPC
- Daily execution triggered by EventBridge
- IAM least-privilege policies for RDS → S3 access
- Optional S3 lifecycle rules for retention & cleanup

---

## 🧩 Modules & Structure

```

.
├── networking.tf         # VPC, subnets, routing, security groups
├── alb.tf                # Application Load Balancer + target groups
├── ec2.tf                # Launch configuration + Auto Scaling Group
├── ecs.tf                # ECS cluster, capacity providers, services
├── iam.tf                # Instance roles, task execution roles
├── secrets.tf            # Secrets Manager integration
├── rds.tf                # PostgreSQL instance in private subnets
├── ecr.tf                # ECR repositories for application images
├── extras/
│   └── backups/
│       ├── s3.tf                  # Backup bucket (secure, private)
│       ├── lambda_rds_to_s3.tf    # Automated database backups
│       └── README.md
└── scripts/
└── ecs-cluster-bootstrap.sh

````

---

## 🚀 Getting Started

### **1. Initialize Terraform**
```bash
terraform init
````

### **2. Review and adjust variables**

Check `variables.tf` for region, environment name, DB credentials, ECR repo names, etc.

### **3. Deploy**

```bash
terraform apply
```

### **4. Output**

Terraform will output:

* ALB URL (ready for testing)
* ECS cluster name
* RDS endpoint
* Backup bucket name (if using extension module)

---

## 🛡 Security & Best Practices

This blueprint already follows several best practices:

* All RDS traffic restricted to SG-to-SG rules
* Private subnets for database instances
* ALB in public subnets, ECS behind it
* Secrets Manager for sensitive values
* IAM policies designed with least-privilege
* S3 bucket with full public access block
* Lifecycle policies for backup retention
* Instance bootstrap via SSM (no public SSH required)
---

## 🎯 Why this project exists

This blueprint was created after analyzing complex real-world production architectures and distilling them into a clean, educational model.
It demonstrates how different AWS services work together to provide:

* scalable compute,
* secure network segmentation,
* automated operations,
* observability,
* and database lifecycle management.

It is ideal for:

* Platform / SRE / DevOps engineers
* Students learning AWS architecture
* Technical interview preparation
* Organizations looking for a reproducible baseline

---

## 📄 License

This repository is intended for educational and professional portfolio use.
You may reuse the patterns and code freely under the MIT License.

