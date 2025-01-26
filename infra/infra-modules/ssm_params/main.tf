data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = var.db_secret_arn
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

resource "aws_ssm_parameter" "app_parameters" {
  for_each = {
    # Web
    "SESSION-SECRET"        = var.session_secret
    "ENCODING-KEY"         = var.encoding_key
    "NODE_ENV"            = var.environment
    
    # Crypto
    "CRYPTO_SALT_SIZE"     = "16"
    "CRYPTO_KEY_LEN"       = "32"
    "CRYPTO_ITERATION_SIZE" = "310000"
    
    # Database
    "API_DB_NAME"          = var.db_name
    "API_DB_HOST"          = var.db_host
    "API_DB_USERNAME" = local.db_creds.username
    "API_DB_PASSWORD" = local.db_creds.password
    "API_DB_PORT"          = "5432"
    "ENABLE_DB_LOGGING"    = "false"  # Set to false in non-dev environments
    
    # Redis
    "REDIS-URL"       = "redis://${var.redis_endpoint}:6379"
    "OPEN_AI_API_SECRET" = "XXXXXXX"
    "OPEN_AI_URL" = "example.com"
    
    # # AWS SES (if needed)
    # "AWS_SES_ACCESS_KEY_ID" = var.ses_access_key_id
    # "AWS_SES_SECRET_ACCESS_KEY" = var.ses_secret_access_key
  }

  name  = "${var.project}-${each.key}-${var.environment}"
  type  = contains(["SESSION_SECRET", "ENCODING_KEY"], each.key) ? "SecureString" : "String"
  value = each.value

  tags = {
    Environment = var.environment
  }
}