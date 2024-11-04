# Input variable: S3 bucket name
variable "bucket_name" {
  description = "Trail Cam Images"
  default = "trail-cam-images"
  type = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-2"  # Change this to your preferred region
}
