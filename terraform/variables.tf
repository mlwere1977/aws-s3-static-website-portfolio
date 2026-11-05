variable "aws_region" {
  description = "Target AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique name for the root static website S3 bucket"
  type        = string
  default     = "mlwere-cs79b-website-2026"
}
