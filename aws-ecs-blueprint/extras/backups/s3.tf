#############################################
# S3 BUCKET FOR RDS BACKUPS
#############################################

# Random suffix for unique bucket names
resource "random_string" "backup_suffix" {
  length           = 16
  special          = true
  override_special = "-"
  upper            = false
}

resource "aws_s3_bucket" "rds_backups" {
  bucket = "${random_string.backup_suffix.result}-rds-backups"
}

# Explicitly private bucket
resource "aws_s3_bucket_acl" "rds_backups_acl" {
  bucket = aws_s3_bucket.rds_backups.id
  acl    = "private"
}

# Block all public access (modern best practice)
resource "aws_s3_bucket_public_access_block" "rds_backups_block" {
  bucket = aws_s3_bucket.rds_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional: retain old backups, delete older than 30 days
resource "aws_s3_bucket_lifecycle_configuration" "cleanup" {
  bucket = aws_s3_bucket.rds_backups.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

output "backup_bucket_name" {
  value = aws_s3_bucket.rds_backups.bucket
}
