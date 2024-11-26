resource "aws_s3_bucket_notification" "image_store_notifications" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  depends_on = [var.lambda_function_arn]
}

variable "bucket_id" {}
variable "lambda_function_arn" {}

output "notification_id" {
  value = aws_s3_bucket_notification.image_store_notifications.id
}
