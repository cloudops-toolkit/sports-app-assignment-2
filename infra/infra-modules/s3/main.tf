locals {
  bucket_name = "${var.project}-s3-${var.environment}"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.bucket_name
  tags = {
    Name = local.bucket_name
  }  
}
resource "aws_s3_bucket_logging" "s3_logging" {
  bucket = local.bucket_name
  target_bucket = local.bucket_name
  target_prefix = "s3-logs/"
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = local.bucket_name
  versioning_configuration {
    status = "Enabled"
  }
}

//Setting ACLs
resource "aws_s3_bucket_ownership_controls" "s3_ownership_controls" {
  bucket = local.bucket_name
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [ aws_s3_bucket.s3_bucket ]
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [aws_s3_bucket.s3_bucket, aws_s3_bucket_ownership_controls.s3_ownership_controls]
  bucket = local.bucket_name
  acl    = "private"
}

//Life-cycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "s3_lc_configuration" {
  bucket = local.bucket_name

  rule {
      id = "glacier_rule"

      transition {
        days          = 30
        storage_class = "GLACIER"
      }

      noncurrent_version_transition {
        noncurrent_days = 60
        storage_class = "GLACIER"
      }

      expiration {
        days = 365
      }
      status = "Enabled"
    }
}

//Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_ss_encryption" {
  bucket = local.bucket_name

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }