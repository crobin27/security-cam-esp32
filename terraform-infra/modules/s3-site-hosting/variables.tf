
variable "bucket_name" {
  description = "Name of the S3 bucket for website hosting"
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