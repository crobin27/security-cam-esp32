module "s3-image-store" {
  source             = "./modules/s3-image-store"
  bucket_name = "s3-image-store"
  lambda_role_arn = module.lambda_iam_role.role_arn
}

module "lambda_presigned_upload" {
  source          = "./modules/lambda/presigned-upload"
  bucket_name     = module.s3_image_store.bucket_name
  lambda_role_arn = module.lambda_iam_role.role_arn
}
output "bucket_name" {
  value = module.s3-image-store.bucket_name
}

output "bucket_arn" {
  value = module.s3-image-store.bucket_arn
}