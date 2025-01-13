# Input variable: S3 bucket name
variable "bucket_name" {
  description = "Trail Cam Images"
  default = "trail-cam-images"
  type = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-1"  # Northern California
}
