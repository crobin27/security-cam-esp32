resource "aws_s3_bucket" "image_store" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
  }
}