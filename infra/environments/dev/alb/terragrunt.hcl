include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/alb"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    public_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

dependency "security_groups" {
  config_path = "../security_groups"
  mock_outputs = {
    alb_sg_id = "sg-00000000"
  }
}

inputs = {
  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  security_group_id = dependency.security_groups.outputs.alb_sg_id
}