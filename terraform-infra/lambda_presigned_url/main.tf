resource "aws_lambda_function" "presign_url_lambda" {
  function_name = "GeneratePresignedURL"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  role          = aws_iam_role.lambda_presign_role.arn  # Attach IAM role

  filename = "${path.module}/lambda_funcs/function.zip"
  timeout  = 10

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name  # Set bucket name as an environment variable
    }
  }
}
