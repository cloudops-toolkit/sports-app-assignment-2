include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../infra-modules/vpc"
}

inputs = {
  vpc_cidr        = include.root.locals.config.vpc.cidr
  azs             = include.root.locals.config.vpc.azs
  public_subnets  = include.root.locals.config.vpc.public_subnets
  private_subnets = include.root.locals.config.vpc.private_subnets
}