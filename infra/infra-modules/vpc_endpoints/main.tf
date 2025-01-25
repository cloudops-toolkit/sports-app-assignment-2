resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project}-vpce-sg-${var.environment}"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.source_security_group_ids
    description     = "Allow HTTPS from ECS and Bastion"
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.source_security_group_ids[0]]  # ECS security group ID
    description     = "Allow HTTPS to ECS tasks"
  }

  tags = {
    Name = "${var.project}-vpce-sg-${var.environment}"
  }
}

# Interface Endpoints
locals {
  interface_endpoints = {
    ecr_api = {
      name        = "ecr.api"
      service     = "ecr.api"
      private_dns = true
    }
    ecr_dkr = {
      name        = "ecr.dkr"
      service     = "ecr.dkr"
      private_dns = true
    }
    logs = {
      name        = "logs"
      service     = "logs"
      private_dns = true
    }
    ssm = {
      name        = "ssm"
      service     = "ssm"
      private_dns = true
    }
    ssmmessages = {
      name        = "ssmmessages"
      service     = "ssmmessages"
      private_dns = true
    }
    ec2messages = {
      name        = "ec2messages"
      service     = "ec2messages"
      private_dns = true
    }
    secrets_manager = {
      name        = "secretsmanager"
      service     = "secretsmanager"
      private_dns = true
    }
    sts = {
      name        = "sts"
      service     = "sts"
      private_dns = true
    }
    # Allow ECS services to communicate with AWS ECS control plane
    ecs = {
      name        = "ecs"
      service     = "ecs"
      private_dns = true
    }
    ecs_agent = {
      name        = "ecs-agent"
      service     = "ecs-agent"
      private_dns = true
    }
    ecs_telemetry = {
      name        = "ecs-telemetry"
      service     = "ecs-telemetry"
      private_dns = true
    }
    rds = {
      name        = "rds"
      service     = "rds"
      private_dns = true
    }
    elasticache = {
      name        = "elasticache"
      service     = "elasticache"
      private_dns = true
    }
    monitoring = {
      name        = "monitoring"
      service     = "monitoring"
      private_dns = true
    }
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = local.interface_endpoints

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value.service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = each.value.private_dns

  tags = {
    Name = "${var.project}-${each.value.name}-${var.environment}"
  }
}

# Gateway Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = {
    Name = "${var.project}-s3-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = {
    Name = "${var.project}-dynamodb-${var.environment}"
  }
}

data "aws_region" "current" {}