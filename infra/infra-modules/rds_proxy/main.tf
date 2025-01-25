resource "aws_iam_role" "rds_proxy" {
  name = "${var.project}-rds-proxy-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy to allow RDS Proxy to access Secrets Manager
resource "aws_iam_role_policy" "rds_proxy_secrets" {
  name = "${var.project}-rds-proxy-secrets-${var.environment}"
  role = aws_iam_role.rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [var.secrets_manager_arn]
      }
    ]
  })
}

# RDS Proxy
resource "aws_db_proxy" "this" {
  name                   = "${var.project}-proxy-${var.environment}"
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn              = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [var.rds_proxy_security_group_id]
  vpc_subnet_ids         = var.private_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "REQUIRED"
    secret_arn  = var.secrets_manager_arn
  }

  tags = {
    Name = "${var.project}-rds-proxy-${var.environment}"
  }
}

# RDS Proxy Target Group
resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent = 100
  }
}

# RDS Proxy Target
resource "aws_db_proxy_target" "this" {
  db_cluster_identifier = var.db_cluster_identifier
  db_proxy_name        = aws_db_proxy.this.name
  target_group_name    = aws_db_proxy_default_target_group.this.name
}