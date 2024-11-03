resource "aws_s3_bucket" "images_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_policy" "images_bucket_policy" {
  bucket = aws_s3_bucket.images_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:PutObject"],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.images_bucket.arn}/*",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

