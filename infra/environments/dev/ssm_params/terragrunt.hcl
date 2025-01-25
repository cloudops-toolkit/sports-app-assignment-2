# environments/dev/ssm_params/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/ssm_params"
}

dependency "redis" {
  config_path = "../redis"
  mock_outputs = {
    redis_endpoint = "mock-redis.xxxxx.cache.amazonaws.com"
    redis_port = "6379"
  }
}

dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    cluster_endpoint = "mock-cluster.xxxxx.region.rds.amazonaws.com"
  }
}

locals {
  environment = include.root.locals.environment
  project = include.root.locals.project
}

inputs = {
  redis_endpoint = dependency.redis.outputs.redis_endpoint
  db_host        = dependency.rds.outputs.cluster_endpoint
  # These should come from environment-specific config files
  session_secret = "xxxxxxx"
  encoding_key   = "xxxxxxx"
  db_secret_arn = dependency.rds.outputs.secrets_manager_secret_arn
  db_name = "${local.project}_db"
}