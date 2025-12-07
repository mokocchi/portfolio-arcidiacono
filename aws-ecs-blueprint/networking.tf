resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-vpc-${var.environment}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-igw-${var.environment}"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    a = {
      cidr = var.public_subnet_cidrs[0]
      az   = "${var.region}a"
    }
    b = {
      cidr = var.public_subnet_cidrs[1]
      az   = "${var.region}b"
    }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}-${var.environment}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    a = {
      cidr = var.private_subnet_cidrs[0]
      az   = "${var.region}a"
    }
    b = {
      cidr = var.private_subnet_cidrs[1]
      az   = "${var.region}b"
    }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "private-${each.key}-${var.environment}"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_db_subnet_group" "rds" {
  name        = "rds-subnet-group-${var.environment}"
  description = "Subnets for RDS"
  subnet_ids  = [for s in aws_subnet.private : s.id]
}

# SG for ALB
resource "aws_security_group" "alb" {
  name        = "alb-sg-${var.environment}"
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-${var.environment}"
  }
}

# SG for ECS instances
resource "aws_security_group" "ecs_instances" {
  name        = "ecs-instances-sg-${var.environment}"
  description = "ECS instances security group"
  vpc_id      = aws_vpc.main.id

  # HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Optional SSH (para labs, restringido a var)
  ingress {
    description = "SSH for admin (lab only)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: restringir a IP corporativa en entornos reales
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-instances-sg-${var.environment}"
  }
}

# SG para acceso a RDS
resource "aws_security_group" "rds_access" {
  vpc_id      = aws_vpc.main.id
  name        = "rds-access-sg-${var.environment}"
  description = "Allow ECS instances to access RDS"

  tags = {
    Name = "rds-access-sg-${var.environment}"
  }
}

resource "aws_security_group" "rds" {
  name   = "rds-sg-${var.environment}"
  vpc_id = aws_vpc.main.id

  # Tráfico de la SG de acceso
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_access.id]
  }

  # Tráfico interno del mismo SG (replicas, mantenimiento)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-${var.environment}"
  }
}
