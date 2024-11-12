resource "aws_s3_bucket" "image_storage" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Production"
  }
}


# Block Public Access for Security
resource "aws_s3_bucket_public_access_block" "image_storage" {
  bucket                  = aws_s3_bucket.image_storage.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Bucket Policy to allow only Lambda to access it through presigned URLs
resource "aws_s3_bucket_policy" "image_storage_policy" {
  bucket = aws_s3_bucket.image_storage.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = var.lambda_role_arn  # Lambda role ARN
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.image_storage.arn}/*"
        ]
      }
    ]
  })
}

