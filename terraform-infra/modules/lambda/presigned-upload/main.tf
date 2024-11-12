resource "aws_lambda_function" "generate_presigned_upload_url" {
  function_name = "GeneratePresignedUploadUrl"
  handler       = "presigned-upload.lambda_handler"
  runtime       = "python3.8"                  # Ensure this matches your Lambda code runtime
  role          = var.lambda_role_arn
  filename      = "../terraform-infra/modules/lambda/function/presigned-url.zip"  # Ensure you zip your Python file

  environment {
    variables = {
      BUCKET_NAME    = var.bucket_name
    }
  }
}