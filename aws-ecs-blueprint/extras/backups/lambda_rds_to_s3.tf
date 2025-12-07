#############################################
# LAMBDA: RDS → S3 BACKUP FUNCTION
#############################################

# Package Lambda code from folder ./lambda
data "archive_file" "rds_backup_package" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "rds_backup" {
  function_name = "rds-to-s3-backup-${var.environment}"
  description   = "Takes a Postgres RDS dump and uploads to S3"
  role          = aws_iam_role.rds_backup_role.arn

  handler = "rds_to_s3.handler"
  runtime = "python3.11"   # podés usar node, provided, etc.

  filename         = data.archive_file.rds_backup_package.output_path
  source_code_hash = filebase64sha256(data.archive_file.rds_backup_package.output_path)

  # Run Lambda inside VPC subnets (for RDS access)
  vpc_config {
    subnet_ids         = [for s in aws_subnet.private : s.id]
    security_group_ids = [aws_security_group.rds_backup_sg.id]
  }

  environment {
    variables = {
      DB_HOST      = aws_db_instance.app.address
      DB_NAME      = var.database_name
      DB_USER      = var.database_username
      DB_PASSWORD  = var.database_password  # En un prod usar Secrets Manager
      BUCKET_NAME  = aws_s3_bucket.rds_backups.bucket
      ENVIRONMENT  = var.environment
    }
  }
}

#############################################
# SECURITY GROUP FOR LAMBDA → RDS ACCESS
#############################################

resource "aws_security_group" "rds_backup_sg" {
  name        = "rds-backup-sg-${var.environment}"
  description = "Allow Lambda to access RDS"
  vpc_id      = aws_vpc.main.id
}

# Allow Lambda to connect to RDS Postgres
resource "aws_security_group_rule" "lambda_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.rds_backup_sg.id
}

#############################################
# IAM ROLE FOR THE LAMBDA
#############################################

data "aws_iam_policy_document" "rds_backup_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_backup_role" {
  name               = "rds-backup-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.rds_backup_assume_role.json
}

# Logging policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.rds_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Access to S3 bucket for writing backups
data "aws_iam_policy_document" "s3_put_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.rds_backups.arn,
      "${aws_s3_bucket.rds_backups.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_put_policy" {
  name   = "allow-lambda-write-s3-${var.environment}"
  policy = data.aws_iam_policy_document.s3_put_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_put" {
  role       = aws_iam_role.rds_backup_role.name
  policy_arn = aws_iam_policy.s3_put_policy.arn
}

#############################################
# SCHEDULE: EVERY DAY AT 3AM UTC
#############################################

resource "aws_cloudwatch_event_rule" "daily_rds_backup" {
  name                = "daily-rds-backup-${var.environment}"
  description         = "Triggers the RDS → S3 backup Lambda once/day"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_backup" {
  rule      = aws_cloudwatch_event_rule.daily_rds_backup.name
  target_id = "rds-backup-lambda"
  arn       = aws_lambda_function.rds_backup.arn
}

resource "aws_lambda_permission" "allow_event" {
  statement_id  = "AllowExecutionFromEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_rds_backup.arn
}
