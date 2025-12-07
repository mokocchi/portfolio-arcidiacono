output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${aws_lb.app.dns_name}/"
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "rds_endpoint" {
  value = aws_db_instance.app.address
}
