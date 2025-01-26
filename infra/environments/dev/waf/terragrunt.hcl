include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra-modules/waf"
}

dependency "cloudfront" {
  config_path = "../cloudfront"
  mock_outputs = {
    # cloudfront_distribution_arn = "arn:aws:cloudfront::123456789012:distribution/EXAMPLE"
    cloudfront_distribution_id = "EXCMALDJDFHSKD"
  }
}

inputs = {
  cloudfront_distribution_id = dependency.cloudfront.outputs.cloudfront_distribution_id
}