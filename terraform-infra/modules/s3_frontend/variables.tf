variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "index_document" {
  description = "Name of the index document"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Name of the error document"
  type        = string
  default     = "error.html"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
