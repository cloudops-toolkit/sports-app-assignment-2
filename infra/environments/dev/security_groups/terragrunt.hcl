include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/security_groups"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  config = include.root.locals.config  # Pass the entire config
}