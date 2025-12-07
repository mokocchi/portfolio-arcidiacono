resource "aws_lb" "app" {
  name               = "app-alb-${var.environment}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.public : s.id]

  tags = {
    Name = "app-alb-${var.environment}"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "app-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance" # mantenemos el espíritu original: ECS sobre EC2 bridge/hostPort

  health_check {
    path                = "/status"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
    matcher             = "200-399"
  }

  tags = {
    Name = "app-tg-${var.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
