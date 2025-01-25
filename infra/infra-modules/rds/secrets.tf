resource "aws_secretsmanager_secret" "aurora_credentials" {
  name = "${var.project}-db-credentials-${var.environment}"
  recovery_window_in_days = 7
  
  tags = {
    Name = "${var.project}-db-credentials-${var.environment}"
  }
}

# Generate random password for the database
resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.master_password.result
    # dbname   = replace("${var.project}_${var.environment}", "-", "_")
    dbname   = "${var.dbname_prefix}_${var.environment}"
    port     = 5432
    engine   = "aurora-postgresql"
  })
}

# Create CloudWatch Log Group for RDS logs
resource "aws_cloudwatch_log_group" "aurora_logs" {
  name              = "/aws/rds/cluster/${var.project}-dbcluster-${var.environment}"
  retention_in_days = 30
  
  tags = {
    Name = "${var.project}-aurora-logs-${var.environment}"
  }
}

# Enhanced Monitoring Role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.project}-rds-monitoring-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}