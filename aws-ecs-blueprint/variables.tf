variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "database_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "database_password" {
  description = "Database password (demo only, use secrets in real envs)"
  type        = string
  sensitive   = true
}

variable "app_images" {
  description = "ECR repositories for the app containers"
  type = map(object({
    name = string
    tag  = string
  }))

  default = {
    backend = {
      name = "web-backend"
      tag  = "latest"
    }
    proxy = {
      name = "web-proxy"
      tag  = "latest"
    }
  }
}
