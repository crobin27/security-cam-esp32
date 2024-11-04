variable "table_name" {
  description = "The name of the DynamoDB table where metadata will be stored"
  type        = string
}

variable "bucket_name" {
  description = "The S3 bucket name where images are uploaded"
  type        = string
}
variable "region" {
  description = "AWS region where resources are deployed"
  type        = string
}
