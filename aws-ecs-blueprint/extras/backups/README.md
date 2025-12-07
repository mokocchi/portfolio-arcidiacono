# RDS → S3 Automated Backup Module

This optional module extends the main AWS ECS platform blueprint by adding a fully automated backup workflow for RDS PostgreSQL databases.  
The goal is to provide a simple, production-inspired pattern for database lifecycle management using Lambda, S3, IAM least privilege, and EventBridge.

---

## ✔️ What this module does

- Creates a **secure, private S3 bucket** dedicated to storing database backups.
- Deploys a **Lambda function inside the VPC** with access to RDS.
- Executes a daily **PostgreSQL dump (pg_dump)** and uploads the file to S3.
- Runs on a **scheduled EventBridge trigger** (cron expression).
- Applies **IAM least-privilege**:
  - Lambda can only read the target RDS instance and write to the backup bucket.
- Includes **optional S3 lifecycle rules** for automated cleanup (e.g., keep 30 days).

---

## 🧠 Architecture Overview

```

EventBridge (daily trigger)
↓
Lambda function inside VPC
↓
pg_dump of RDS PostgreSQL
↓
Upload to private S3 bucket
↓
Optional lifecycle cleanup after N days

````

---

## 📁 Module contents

- **`s3.tf`**  
  Creates a randomized private S3 bucket for RDS backups plus optional lifecycle rules.

- **`lambda_rds_to_s3.tf`**  
  Lambda function, IAM roles, VPC config, CloudWatch logs, and EventBridge schedule.

- **`lambda/`**  
  Folder containing the Lambda source code (not provided in this blueprint).

---

## 🚀 How to enable this module

In the root `main.tf` (or wherever you aggregate modules):

```hcl
module "backups" {
  source      = "./extras/backups"
  environment = var.environment
}
````

Then:

```bash
terraform init
terraform apply
```

Terraform will output the generated S3 backup bucket name.

---

## 🔒 Security Notes

* The Lambda runs in **private subnets** to access RDS securely.
* The `rds_backup_sg` security group allows traffic **only to port 5432** of the RDS SG.
* IAM policies grant:

  * minimal S3 `PutObject` permissions,
  * no broad `s3:*` access,
  * no administrative privileges.
* No public access is allowed on the backup bucket.

---

## 🎯 When to use this module

This extension is useful for:

* environments without AWS Backup service enabled,
* teams wanting to understand “manual” backup patterns,
* educational or demo platforms,
* migrations requiring ad-hoc dumps,
* interview prep or portfolio demonstrations.

---

## ℹ️ Disclaimer

This backup module is a simplified educational pattern.
In production, consider additional topics:

* encryption keys (KMS),
* Secrets Manager for DB credentials,
* reducing Lambda package size,
* larger datasets requiring multi-part uploads,
* AWS Backup or managed snapshot schedules.
