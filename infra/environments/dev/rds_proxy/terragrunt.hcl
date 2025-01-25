include "root" {
  path = find_in_parent_folders()
  expose = true
}

skip = !try(include.root.locals.config.rds_proxy.enabled, false)

terraform {
  source = "../../../infra-modules/rds_proxy"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    cluster_identifier = "mock-db-cluster"
    secrets_manager_secret_arn = "arn:aws:secretsmanager:region:123456789012:secret:mock-secret"
  }
}

dependency "security_groups" {
  config_path = "../security_groups"
  mock_outputs = {
    rds_proxy_sg_id = "sg-00000000"
  }
}

inputs = {
  vpc_id                = dependency.vpc.outputs.vpc_id
  private_subnet_ids    = dependency.vpc.outputs.private_subnet_ids
  db_cluster_identifier = dependency.rds.outputs.cluster_identifier
  secrets_manager_arn   = dependency.rds.outputs.secrets_manager_secret_arn
  rds_proxy_security_group_id = dependency.security_groups.outputs.rds_proxy_sg_id
}