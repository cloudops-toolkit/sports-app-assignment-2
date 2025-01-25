include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/asg"
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

dependency "ecs" {
  config_path = "../ecs"
  mock_outputs = {
    cluster_name = "mock-ecs-cluster"
  }
}

inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  private_subnet_ids   = dependency.vpc.outputs.private_subnet_ids
  ecs_security_group_id = dependency.security_groups.outputs.ecs_sg_id
  cluster_name         = dependency.ecs.outputs.cluster_name
}