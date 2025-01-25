include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/vpc_endpoints"
}


dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
    private_route_table_ids = ["rtb-private1"]
  }
}

dependency "security_groups" {
  config_path = "../security_groups"
  mock_outputs = {
    ecs_sg_id = "sg-12345678"
    bastion_sg_id = "sg-87654321"
  }
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  route_table_ids    = dependency.vpc.outputs.private_route_table_ids
  source_security_group_ids = [
    dependency.security_groups.outputs.ecs_sg_id,
    dependency.security_groups.outputs.bastion_sg_id
  ]
}