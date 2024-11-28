# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "s3-frontend" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "s3-frontend" {
  bucket = aws_s3_bucket.s3-frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public Access Policy
resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.s3-frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.s3-frontend.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket       = "esp32-frontend-hosting"
  key          = "index.html"
  source       = "E:/trail-cam-esp32/web-frontend/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "script_js" {
  bucket       = "esp32-frontend-hosting"
  key          = "script.js"
  source       = "E:/trail-cam-esp32/web-frontend/script.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "styles_css" {
  bucket       = "esp32-frontend-hosting"
  key          = "styles.css"
  source       = "E:/trail-cam-esp32/web-frontend/styles.css"
  content_type = "text/css"
}
