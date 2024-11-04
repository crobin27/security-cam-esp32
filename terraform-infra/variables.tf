# Input variable: S3 bucket name
variable "bucket_name" {
  description = "Trail Cam Images"
  default = "trail-cam-images"
  type = string
}