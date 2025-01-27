variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "A description of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "The deployment stage name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_display_photos" {
  description = "The ARN of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "lambda_upload_photo" {
  description = "The ARN of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "lambda_iot_command" {
  description = "The ARN of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-1"
}

data "aws_caller_identity" "current" {}