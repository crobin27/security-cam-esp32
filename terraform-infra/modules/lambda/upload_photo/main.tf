# Lambda Function
resource "aws_lambda_function" "upload_photo" {
  filename         = "${path.module}/upload_photo.zip" # Path to the zipped Lambda code
  function_name    = "UploadPhotoHandler"
  handler          = "upload_photo.lambda_handler"
  runtime          = "python3.9"
  role             = var.lambda_iam_role_arn
  source_code_hash = filebase64sha256("${path.module}/upload_photo.zip")

  environment {
    variables = {
      IMAGE_STORE_BUCKET = var.image_store_bucket
    }
  }

  tags = {
    Name = "UploadPhotoLambda"
  }
}