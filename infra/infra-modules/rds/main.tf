resource "aws_rds_cluster_parameter_group" "aurora" {
  family = "aurora-postgresql14"
  name   = "${var.project}-params-${var.environment}"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # Log queries that take more than 1 second
  }

  parameter {
    name  = "rds.force_ssl"
    value = "0" //temporary
  }
}

resource "aws_db_subnet_group" "aurora" {
  name        = "${var.project}-db-subnet-${var.environment}"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for Aurora"
}

data "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id
  depends_on = [aws_secretsmanager_secret_version.aurora_credentials]
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "${var.project}-dbcluster-${var.environment}"
  engine                = "aurora-postgresql"
  engine_version        = "14.8"

# For Aurora Serverless v1 (EOL March 2025)
# resource "aws_rds_cluster" "aurora" {
#   cluster_identifier     = "${var.project}-cluster-${var.environment}"
#   engine                = "aurora-postgresql"
#   engine_mode           = "serverless"
#   engine_version        = "13.12"

  # For serverlessv2
  serverlessv2_scaling_configuration {
    min_capacity = 0.5  # Minimum capacity in ACUs
    max_capacity = 8.0  # Maximum capacity in ACUs
  }

  # Get credentials from Secrets Manager
  database_name         = jsondecode(data.aws_secretsmanager_secret_version.aurora_credentials.secret_string)["dbname"]
  master_username       = jsondecode(data.aws_secretsmanager_secret_version.aurora_credentials.secret_string)["username"]
  master_password      = jsondecode(data.aws_secretsmanager_secret_version.aurora_credentials.secret_string)["password"]
  
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  
  # Backup Configuration
  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  # Security Configuration
  storage_encrypted        = true
  deletion_protection      = var.deletion_protection
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  skip_final_snapshot = true  # You might want to set this to false in production
}

resource "aws_rds_cluster_instance" "aurora" {
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class    = "db.serverless"  # This indicates Serverless v2
  engine            = aws_rds_cluster.aurora.engine
  engine_version    = aws_rds_cluster.aurora.engine_version
}

# Create SNS Topic for RDS Events
resource "aws_sns_topic" "rds_events" {
  name = "${var.project}-rds-events-${var.environment}"
}

# Create Event Subscription
resource "aws_db_event_subscription" "rds_events" {
  name      = "${var.project}-rds-event-subs-${var.environment}"
  sns_topic = aws_sns_topic.rds_events.arn

  source_type = "db-cluster"
  source_ids  = [aws_rds_cluster.aurora.id]

  event_categories = [
    "configuration change",
    "creation",
    "deletion",
    "failover",
    "failure",
    "maintenance",
    "notification"
  ]
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.project}-db-connections-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "This metric monitors database connections"
  alarm_actions       = [aws_sns_topic.rds_events.arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }
}