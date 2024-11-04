resource "aws_s3_bucket" "images_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = "Development"
    Project     = "ESP32-Trail-Cam"
  }


}

# Enable versioning if needed
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.images_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
  lifecycle {
    ignore_changes = [versioning_configuration] # Prevent re-creation on changes
  }
}

# Define server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.images_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  lifecycle {
    ignore_changes = [rule] # Ignore re-creation if encryption rule changes
  }
}
