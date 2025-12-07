resource "aws_db_instance" "app" {
  identifier             = "webapp-db-${var.environment}"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  db_name                = var.database_name
  username               = var.database_username
  password               = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 3
  skip_final_snapshot     = true # Lab; en prod → false + snapshot_identifier

  tags = {
    Name = "webapp-db-${var.environment}"
  }
}
