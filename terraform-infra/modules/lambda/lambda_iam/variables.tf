variable "image_store_bucket" {
  description = "Name of the S3 bucket storing images"
  type        = string
}

variable "image_store_bucket_arn" {
  description = "ARN of the S3 bucket storing images"
  type        = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-1"
}

data "aws_caller_identity" "current" {}