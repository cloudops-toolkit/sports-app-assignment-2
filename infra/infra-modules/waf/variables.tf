variable "project" {
  type = string
}

variable "environment" {
  type = string
}

# variable "cloudfront_distribution_arn" {
#   type = string
# }

variable "cloudfront_distribution_id" {
  type        = string
  description = "The ID of the CloudFront distribution to associate with the WAF Web ACL"
  
  validation {
    condition     = can(regex("^[A-Z0-9]{13,14}$", var.cloudfront_distribution_id))
    error_message = "The CloudFront distribution ID must be a 13-14 character string containing only uppercase letters and numbers."
  }
}