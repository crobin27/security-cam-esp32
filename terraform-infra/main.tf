module "s3-frontend" {
  source         = "./modules/s3-frontend"
  bucket_name    = "esp32-frontend-hosting" # Replace with a globally unique name
  index_document = "index.html"
  error_document = "error.html"
  environment    = "dev"
}

output "static_site_url" {
  description = "The S3 static website endpoint"
  value       = module.s3-frontend.website_endpoint
}
