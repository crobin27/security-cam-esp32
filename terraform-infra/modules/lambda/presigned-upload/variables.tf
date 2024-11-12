variable "bucket_name" {
  description = "The name of the S3 bucket for image storage."
  type        = string
}

variable "lambda_role_arn" {
  description = "The IAM role ARN for the Lambda function."
  type        = string
}