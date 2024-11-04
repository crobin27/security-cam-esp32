resource "aws_lambda_function" "presign_url_lambda" {
  function_name = "GeneratePresignedURL"
  handler       = "index.handler"
  runtime       = "nodejs16.x"  # Node.js 16.x runtime
  role          = aws_iam_role.lambda_role.arn

  filename      = "${path.module}/lambda-funcs/generate-presigned-url/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-funcs/generate-presigned-url/function.zip")

  timeout       = 10  # Increase timeout to 10 seconds for testing

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.images_bucket.bucket
    }
  }
}
