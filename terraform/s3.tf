resource "aws_s3_bucket" "webapp_bucket" {
  bucket        = "private-${var.PROFILE}-${random_id.random_bucket_id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "webapp_bucket_acl" {
  bucket = aws_s3_bucket.webapp_bucket.id
  acl    = var.s3_bucket_acl
}

resource "aws_s3_bucket_server_side_encryption_configuration" "webapp_encryption" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "webapp_transition" {
  bucket = aws_s3_bucket.webapp_bucket.id
  rule {
    status = var.webapp_transition_status
    id     = var.s3_bucket_rule_id

    transition {
      days          = var.webapp_transition_days
      storage_class = var.webapp_transition_storage
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket                  = aws_s3_bucket.webapp_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_id" "random_bucket_id" {
  byte_length = 4
}