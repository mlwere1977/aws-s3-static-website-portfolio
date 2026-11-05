output "website_bucket_name" {
  description = "Name of the static website S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
}

output "website_endpoint" {
  description = "Direct HTTP S3 static website hosting endpoint"
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

output "logging_bucket_name" {
  description = "Name of the private logging bucket"
  value       = aws_s3_bucket.logging_bucket.id
}
