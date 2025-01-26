# WAFv2 Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project}-waf-${var.environment}"
  description = "WAF for ${var.project} in ${var.environment}"
  scope       = "CLOUDFRONT" # WAF attached to CloudFront

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }

  rule {
    name     = "LimitRequests"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name                = "LimitRequests"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-waf-metrics"
    sampled_requests_enabled   = true
  }
}

# Web ACL Association with CloudFront
resource "aws_wafv2_web_acl_association" "cloudfront" {
  # resource_arn = var.cloudfront_distribution_arn
  resource_arn = "arn:aws:cloudfront::418272773173:distribution/${var.cloudfront_distribution_id}"
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
