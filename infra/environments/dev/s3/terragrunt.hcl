include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/s3"
}

inputs = {
  bucket_name = local.config.s3.bucket_name
  versioning_enabled = local.config.s3.versioning_enabled
}