include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]  # Usually RDS needs multiple subnets
  }
}

dependency "security_groups" {
  config_path = "../security_groups"
  mock_outputs = {
    rds_sg_id = "sg-00000000"
  }
}

locals {
  environment = include.root.locals.environment
  project = include.root.locals.project
  dbname_prefix = include.root.locals.dbname_prefix
}

inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  private_subnet_ids   = dependency.vpc.outputs.private_subnet_ids
  rds_security_group_id = dependency.security_groups.outputs.rds_sg_id
  dbname_prefix        = "${local.dbname_prefix}"
  # Environment-specific configurations
  backup_retention_period = try(include.root.locals.config.rds.backup_retention_period, 7)
  preferred_backup_window = try(include.root.locals.config.rds.preferred_backup_window, "03:00-04:00")
  preferred_maintenance_window = try(include.root.locals.config.rds.preferred_maintenance_window, "Mon:04:00-Mon:05:00")
  deletion_protection = try(include.root.locals.config.rds.deletion_protection, true)
}