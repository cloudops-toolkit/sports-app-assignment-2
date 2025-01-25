include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/waf"
}

dependency "cloudfront" {
  config_path = "../cloudfront-s3"
  mock_outputs = {
    cloudfront_distribution_arn = "arn:aws:cloudfront::123456789012:distribution/EXAMPLE"
  }
}

inputs = {
  cloudfront_distribution_arn = dependency.cloudfront.outputs.cloudfront_distribution_arn
}