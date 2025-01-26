include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/ecs"
}

locals {
  use_proxy   = try(include.root.locals.config.rds_proxy.enabled, false)
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

dependency "security_groups" {
  config_path = "../security_groups"
  mock_outputs = {
    ecs_sg_id = "sg-00000000"
  }
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/mock-tg/0123456789abcdef"
  }
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    repository_url = "123456789012.dkr.ecr.us-west-2.amazonaws.com/mock-repo"
  }
}

dependency "rds_proxy" {
  config_path = "../rds_proxy"
  mock_outputs = {
    proxy_endpoint = "mock-proxy-endpoint.proxy-123456789012.us-west-2.rds.amazonaws.com"
  }
}

dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    secrets_manager_secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:mock-secret-123456"
    cluster_endpoint = "mock-cluster-endpoint.cluster-123456789012.us-west-2.rds.amazonaws.com"
  }
}

dependency "redis" {
  config_path = "../redis"
  mock_outputs = {
    redis_endpoint = "mock-redis.xxxxx.cache.amazonaws.com"
    redis_port = "6379"
  }
}

dependency "ssm_params" {
  config_path = "../ssm_params"
  mock_outputs = {
    ssm_parameter_arns = {
      "SESSION_SECRET" = "arn:aws:ssm:region:account:parameter/mock-session-secret"
      "ENCODING_KEY"   = "arn:aws:ssm:region:account:parameter/mock-encoding-key"
      "REDIS_URL"      = "arn:aws:ssm:region:account:parameter/mock-redis-url"
    }
  }
}

inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  private_subnet_ids   = dependency.vpc.outputs.private_subnet_ids
  ecs_security_group_id = dependency.security_groups.outputs.ecs_sg_id
  target_group_arn     = dependency.alb.outputs.target_group_arn
  ecr_repository_url   = dependency.ecr.outputs.repository_url
  db_cluster_endpoint = dependency.rds.outputs.cluster_endpoint
  rds_proxy_endpoint   = local.use_proxy ? dependency.rds_proxy.outputs.proxy_endpoint : null
  db_secret_arn        = dependency.rds.outputs.secrets_manager_secret_arn
  redis_endpoint = dependency.redis.outputs.redis_endpoint
  ssm_parameter_arns = dependency.ssm_params.outputs.ssm_parameter_arns
}