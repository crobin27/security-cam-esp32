# modules/s3_site_hosting/outputs.tf

output "bucket_name" {
  value = aws_s3_bucket.site_hosting.bucket
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.site_distribution.domain_name
}