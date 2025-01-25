output "cloudfront_domain_name" {
  description = "domain name of CloudFront distribution"
  value       = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.cloudfront_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution arn"
  value       = aws_cloudfront_distribution.cloudfront_distribution.arn
}