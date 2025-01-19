variable "image_store_bucket" {
  description = "Name of the S3 bucket storing images"
  type        = string
}

variable "image_store_bucket_arn" {
  description = "ARN of the S3 bucket storing images"
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "The ARN of the Lambda function to integrate with API Gateway"
  type        = string
}