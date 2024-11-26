/* S3 bucket responsible for frontend site hosting */
module "s3_frontend" {
  source         = "./modules/s3_frontend"
  bucket_name    = "esp32-frontend-hosting"
  index_document = "index.html"
  error_document = "error.html"
  environment    = "dev"
}

/* API Gateway handling all requests/responses between AWS Services and devices */
module "api_gateway" {
  source = "./modules/api_gateway"
}

/* S3 Image Store */
module "s3_image_store" {
  source      = "./modules/s3_image_store"
  bucket_name = "esp32-image-store"
}

/* DynamoDB for image metadata */
module "dynamodb" {
  source            = "./modules/dynamodb"
  dynamo_table_name = "esp32-image-metadata"
}

/* Lambda function to trigger DynamoDB updates */
module "s3_to_dynamo_lambda" {
  source                 = "./modules/lambda/dynamodb_trigger"
  dynamo_table_name      = module.dynamodb.dynamo_table_name
  dynamo_table_arn       = module.dynamodb.dynamo_table_arn
  image_store_bucket_arn = module.s3_image_store.bucket_arn
}

/* S3 bucket notifications */
module "s3_bucket_notification" {
  source              = "./modules/s3_bucket_notification"
  bucket_id           = module.s3_image_store.bucket_id
  lambda_function_arn = module.s3_to_dynamo_lambda.lambda_function_arn
}
