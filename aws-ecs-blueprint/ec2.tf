data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized*"]
  }
}

data "template_file" "ecs_bootstrap" {
  template = file("scripts/ecs-cluster-bootstrap.sh")
}

resource "aws_launch_configuration" "ecs" {
  name_prefix                 = "ecs-asg-${var.environment}-"
  image_id                    = data.aws_ami.ecs_optimized.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true # Lab; en prod → subnets privadas + solo SSM
  user_data                   = data.template_file.ecs_bootstrap.rendered
  security_groups             = [aws_security_group.ecs_instances.id, aws_security_group.rds_access.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ecs-key-${var.environment}"
  public_key = "ssh-rsa AAAA...REPLACE_ME..."
}

resource "aws_autoscaling_group" "ecs" {
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_configuration  = aws_launch_configuration.ecs.name
  vpc_zone_identifier   = [for s in aws_subnet.public : s.id]
  protect_from_scale_in = true

  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns]
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "ecs-instance-${var.environment}"
    propagate_at_launch = true
  }
}
