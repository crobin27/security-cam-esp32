/* S3 bucket responsible for frontend site hosting */
module "s3_frontend" {
  source         = "./modules/s3_frontend"
  bucket_name    = "esp32-frontend-hosting"
  index_document = "index.html"
  error_document = "error.html"
  environment    = "dev"
}

/* S3 Image Store */
module "s3_image_store" {
  source      = "./modules/s3_image_store"
  bucket_name = "esp32-image-store"
}

/* API Gateway */
module "api_gateway" {
  source             = "./modules/api_gateway"
  api_name           = "ESP32-API"
  api_description    = "API Gateway for ESP32 Communication"
  stage_name         = "dev"
  lambda_function_arn = module.display_photos_lambda.lambda_function_arn
}

/* Lambda Function for Display Photos */
module "display_photos_lambda" {
  source                 = "./modules/lambda/display_photos"
  image_store_bucket     = module.s3_image_store.bucket_name
  image_store_bucket_arn = module.s3_image_store.bucket_arn
}