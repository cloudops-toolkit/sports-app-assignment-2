include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/cloudfront"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
  s3_bucket_name = ""  
  }
}

inputs = {
  bucket_name = dependency.s3.outputs.s3_bucket_name
}