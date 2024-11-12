resource "aws_s3_bucket" "site_hosting" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Production"
  }
}

# For public access on S3 bucket
resource "aws_s3_bucket_public_access_block" "site_hosting" {
  bucket                  = aws_s3_bucket.site_hosting.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


# Optional: CloudFront Distribution for S3 Website
resource "aws_cloudfront_distribution" "site_distribution" {
   restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  origin {
    domain_name = aws_s3_bucket.site_hosting.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.site_hosting.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.site_hosting.bucket}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# CloudFront Origin Access Identity to restrict access
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 website hosting bucket"
}

# Add bucket policy to allow access only via CloudFront OAI
resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site_hosting.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.site_hosting.arn}/*",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
      }
    ]
  })
}