include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/s3_bucket_policy"
}

dependency "s3" {
  config_path = "../s3"
   mock_outputs = {
  s3_bucket_name = ""
  }
//   skip_outputs = true
}

dependency "cloudfront" {
    config_path = "../cloudfront"
    mock_outputs= {
    cloudfront_distribution_id = ""
    }
}

inputs = {
    bucket_name = dependency.s3.outputs.s3_bucket_name
    cloudfront_distribution_id = dependency.cloudfront.outputs.cloudfront_distribution_id

}