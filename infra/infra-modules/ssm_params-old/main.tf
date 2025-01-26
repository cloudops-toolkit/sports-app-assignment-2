data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = var.db_secret_arn
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

resource "aws_ssm_parameter" "app_parameters" {
  for_each = {
    # Web
    "SESSION-SECRET"   = var.session_secret
    "ENCODING-KEY"     = var.encoding_key
    "NODE_ENV"         = var.environment
    
    # Database
    "API_DB_NAME"      = var.db_name
    "API_DB_HOST"      = var.db_host
    "API_DB_USERNAME"  = local.db_creds.username
    "API_DB_PASSWORD"  = local.db_creds.password
    "API_DB_PORT"      = "5432"
    
    # Redis
    "REDIS-URL"        = "redis://${var.redis_endpoint}:6379"
  }

  name  = "${var.project}-${each.key}-${var.environment}"
  type  = contains(["SESSION-SECRET", "ENCODING-KEY", "API_DB_USERNAME", "API_DB_PASSWORD"], each.key) ? "SecureString" : "String"
  value = each.value

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}