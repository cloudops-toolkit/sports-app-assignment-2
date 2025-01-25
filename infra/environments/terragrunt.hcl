locals {
  # Instead of parsing from path, get from environment variable set by GitHub Actions
  environment = get_env("TF_VAR_environment")
  project     = get_env("TF_VAR_project")
  aws_primary_region  = get_env("AWS_PRIMARY_REGION")

  # Add validation
  validate_vars = (
    local.environment == "" ? file("ERROR: TF_VAR_environment is not set") :
    local.project == "" ? file("ERROR: TF_VAR_project is not set") :
    local.aws_primary_region == "" ? file("ERROR: aws_primary_region is not set") : 
    null
  )

  # Get paths - using find_in_parent_folders() to go up to the repo root
  config_path = "${dirname(dirname(dirname(get_terragrunt_dir())))}/config/${local.environment}.yaml"

  # Load config with validation
  config = fileexists(local.config_path) ? (
    yamldecode(file(local.config_path))
  ) : (
    file("ERROR: Configuration file not found at ${local.config_path}")
  )

  default_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "terraform"
  }

  # Merge both tag maps
  all_tags = merge(local.default_tags, local.config.tags)
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "${local.project}-s3-terraform-state-${local.environment}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_primary_region
    encrypt        = true
    dynamodb_table = "${local.project}-terraform-locks-${local.environment}"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_primary_region}"
  default_tags {
    tags = ${jsonencode(local.all_tags)}
  }
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
}

inputs = {
  environment = local.environment
  project     = local.project
  aws_primary_region  = local.aws_primary_region
}

