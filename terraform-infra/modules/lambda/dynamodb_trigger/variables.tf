variable "image_store_bucket_arn" {
  description = "ARN of the S3 Image Store bucket"
  type        = string
}

variable "dynamo_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

variable "dynamo_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}
