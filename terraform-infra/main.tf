/* S3 buckets*/
module "s3_frontend" {
  source         = "./modules/s3_frontend"
  bucket_name    = "esp32-frontend-hosting"
  index_document = "index.html"
  error_document = "error.html"
  environment    = "dev"
}

module "s3_image_store" {
  source      = "./modules/s3_image_store"
  bucket_name = "esp32-image-store"
}


/* Lambda Infrastructure */
module "lambda_iam" {
  source                 = "./modules/lambda/lambda_iam"
  image_store_bucket     = module.s3_image_store.bucket_name
  image_store_bucket_arn = module.s3_image_store.bucket_arn
}

module "display_photos_lambda" {
  source                 = "./modules/lambda/display_photos"
  image_store_bucket     = module.s3_image_store.bucket_name
  image_store_bucket_arn = module.s3_image_store.bucket_arn
  lambda_iam_role_arn    = module.lambda_iam.lambda_iam_role_arn
}

module "upload_photo_lambda" {
  source                 = "./modules/lambda/upload_photo"
  image_store_bucket     = module.s3_image_store.bucket_name
  image_store_bucket_arn = module.s3_image_store.bucket_arn
  lambda_iam_role_arn    = module.lambda_iam.lambda_iam_role_arn
}

module "iot_command_lambda" {
  source              = "./modules/lambda/iot_command"
  lambda_iam_role_arn = module.lambda_iam.lambda_iam_role_arn
}

/* API Gateway */
module "api_gateway" {
  source                = "./modules/api_gateway"
  api_name              = "ESP32-API"
  api_description       = "API Gateway for ESP32 Communication"
  stage_name            = "dev"
  lambda_display_photos = module.display_photos_lambda.lambda_function_arn
  lambda_upload_photo   = module.upload_photo_lambda.lambda_function_arn
  lambda_iot_command     = module.iot_command_lambda.lambda_function_arn
}

/* IoT Thing */
module "iot" {
  source     = "./modules/iot"
  thing_name = "esp32-thing"
}