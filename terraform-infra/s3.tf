# Define the main S3 bucket for storing images
resource "aws_s3_bucket" "images_bucket" {
  bucket = var.bucket_name
  tags = {
    Environment = "Development"
    Project     = "ESP32-Trail-Cam"
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.images_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Define server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.images_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
