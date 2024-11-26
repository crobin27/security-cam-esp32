output "website_endpoint" {
  description = "The URL of the static website"
  value       = aws_s3_bucket_website_configuration.s3-frontend.website_endpoint
}
