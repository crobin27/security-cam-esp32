# Lambda Function
resource "aws_lambda_function" "display_photos" {
  filename         = "${path.module}/display_photos.zip" # Path to the zipped Lambda code
  function_name    = "DisplayPhotosHandler"
  handler          = "display_photos.lambda_handler"
  runtime          = "python3.9"
  role             = var.lambda_iam_role_arn

  environment {
    variables = {
      IMAGE_STORE_BUCKET = var.image_store_bucket
    }
  }

  tags = {
    Name = "DisplayPhotosLambda"
  }
}
