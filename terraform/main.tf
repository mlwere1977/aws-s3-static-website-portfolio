terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Private S3 Bucket for Server Access Logs
resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "logs.${var.bucket_name}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "logging_controls" {
  bucket = aws_s3_bucket.logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logging_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logging_controls]
  bucket     = aws_s3_bucket.logging_bucket.id
  acl        = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "logging_block" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Public S3 Bucket for Static Website
resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "website_public_block" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_logging" "website_logging" {
  bucket = aws_s3_bucket.website_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "root-website-logs/"
}

# 3. Bucket Policy allowing Public Read for Website Objects
resource "aws_s3_bucket_policy" "allow_public_read" {
  depends_on = [aws_s3_bucket_public_access_block.website_public_block]
  bucket     = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
