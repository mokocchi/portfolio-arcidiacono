resource "aws_secretsmanager_secret" "database_url" {
  name = "webapp-database-url-${var.environment}"

  tags = {
    Application = "webapp"
  }
}

resource "aws_secretsmanager_secret_version" "database_url_version" {
  secret_id = aws_secretsmanager_secret.database_url.id

  secret_string = "postgres://${var.database_username}:${var.database_password}@${aws_db_instance.app.address}/${var.database_name}"
}
