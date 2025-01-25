variable "cloudfront_distribution_id" {
  description = "Cloudfront distribution id"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "project" {
  type        = string
  description = "Project name"
}