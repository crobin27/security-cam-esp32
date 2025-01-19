variable "thing_name" {
  description = "The name of the IoT Thing"
  type        = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-1"
}