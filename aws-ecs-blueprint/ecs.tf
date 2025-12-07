resource "aws_ecs_cluster" "main" {
  name = "webapps-cluster-${var.environment}"
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "ecs-ec2-capacity-provider-${var.environment}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 70
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_providers" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.ec2.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 100
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/webapp-${var.environment}"
  retention_in_days = 90
}

locals {
  app_container_definitions = [
    {
      name      = "backend-app"
      hostname  = "backend-app"
      image     = "${aws_ecr_repository.app["backend"].repository_url}:${var.app_images["backend"].tag}"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      environment = [
        {
          name  = "APP_ENV"
          value = var.environment
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.database_url.arn
        }
      ]

      memory = 512
      cpu    = 256

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend"
        }
      }

      healthCheck = {
        command  = ["CMD-SHELL", "curl -f http://localhost:3000/status || exit 1"]
        interval = 10
        timeout  = 5
        retries  = 5
      }
    },
    {
      name      = "web-proxy"
      image     = "${aws_ecr_repository.app["proxy"].repository_url}:${var.app_images["proxy"].tag}"
      essential = true

      links = ["backend-app"]

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      dependsOn = [
        {
          containerName = "backend-app"
          condition     = "HEALTHY"
        }
      ]

      environment = [
        {
          name  = "UPSTREAM_HOST"
          value = "backend-app"
        },
        {
          name  = "UPSTREAM_PORT"
          value = "3000"
        }
      ]

      memory = 512
      cpu    = 256

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "proxy"
        }
      }
    }
  ]
}

resource "aws_ecs_task_definition" "webapp" {
  family                   = "webapp-task-${var.environment}"
  network_mode             = "bridge"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["EC2"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode(local.app_container_definitions)
}

resource "aws_ecs_service" "webapp" {
  name            = "webapp-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.webapp.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 100
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}
