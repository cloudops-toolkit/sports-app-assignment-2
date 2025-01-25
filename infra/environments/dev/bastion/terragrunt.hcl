include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/bastion"
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
    bastion_sg_id = "sg-00000000"
  }
}

inputs = {
  vpc_id            = dependency.vpc.outputs.vpc_id
  private_subnet_id = dependency.vpc.outputs.private_subnet_ids[0]
  bastion_security_group_id = dependency.security_groups.outputs.bastion_sg_id
}