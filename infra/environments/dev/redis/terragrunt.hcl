# environments/dev/redis/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/redis"
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
    redis_sg_id = "sg-12345678"
  }
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  security_group_id  = dependency.security_groups.outputs.redis_sg_id
}