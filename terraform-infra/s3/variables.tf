variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
variable "lambda_trigger_arn" {
  description = "The ARN of the Lambda function to trigger on S3 events"
  type        = string
}
