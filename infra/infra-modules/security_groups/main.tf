resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg-${var.environment}"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
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
    Name = "${var.project}-alb-sg-${var.environment}"
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.project}-ecs-sg-${var.environment}"
  description = "ECS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0  # Allow all ports for debugging
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  tags = {
    Name = "${var.project}-ecs-sg-${var.environment}"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg-${var.environment}"
  description = "RDS Security Group"
  vpc_id      = var.vpc_id

  # Dynamic block for RDS ingress rules
  dynamic "ingress" {
    for_each = try(var.config.rds_proxy.enabled, false) ? [1] : []
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [aws_security_group.rds_proxy.id]
    }
  }

  # Direct access if proxy is not enabled
  dynamic "ingress" {
    for_each = try(var.config.rds_proxy.enabled, false) ? [] : [1]
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [aws_security_group.ecs.id, aws_security_group.bastion.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-sg-${var.environment}"
  }
}

# resource "aws_security_group" "rds" {
#   name        = "${var.project}-rds-sg-${var.environment}"
#   description = "RDS Security Group"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs.id]
#   }

#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.bastion.id]
#   }

#   tags = {
#     Name = "${var.project}-rds-sg-${var.environment}"
#   }
# }

resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-host-sg-${var.environment}"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-bastion-host-sg-${var.environment}"
  }
}

# RDS Proxy Security Group - Will only be referenced when enabled in config
resource "aws_security_group" "rds_proxy" {
  name        = "${var.project}-rdsproxy-sg-${var.environment}"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rdsproxy-sg-${var.environment}"
  }
}

# # Security Group for RDS Proxy
# resource "aws_security_group" "rds_proxy" {
#   name        = "${var.project}-rdsproxy-sg-${var.environment}"
#   description = "Security group for RDS Proxy"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.rds.id]
#   }
  
#   # Add ingress from ECS
#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs.id]
#   }

#   # Add ingress from bastion
#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.bastion.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project}-rdsproxy-sg-${var.environment}"
#   }
# }

resource "aws_security_group" "redis" {
  name        = "${var.project}-redis-sg-${var.environment}"
  description = "Redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-redis-sg-${var.environment}"
  }
}