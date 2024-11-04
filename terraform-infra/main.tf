module "s3" {
  source             = "./s3"
  bucket_name        = var.bucket_name
  lambda_trigger_arn = module.dynamo_trigger.lambda_function_arn  # Pass the Lambda ARN
}


module "dynamodb" {
  source     = "./dynamodb"
  table_name = "ImageMetadata"  # Set the name of your DynamoDB table here
}

module "lambda_presigned_url" {
  source      = "./lambda_presigned_url"
  bucket_name = module.s3.bucket_name  # Pass the bucket name to the Lambda module
}

module "dynamo_trigger" {
  source      = "./dynamo_trigger"
  bucket_name = module.s3.bucket_name       # Pass S3 bucket name from S3 module
  table_name  = module.dynamodb.table_name  # Pass DynamoDB table name from DynamoDB module
  region      = var.region                  # Pass AWS region
}

