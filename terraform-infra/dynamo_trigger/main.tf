# Lambda function definition for DynamoDB trigger
resource "aws_lambda_function" "dynamo_trigger" {
  function_name = "S3ToDynamoDBHandler"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  role          = aws_iam_role.lambda_dynamo_role.arn

  filename      = "${path.module}/lambda_funcs/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_funcs/function.zip")

  environment {
    variables = {
      TABLE_NAME  = var.table_name
      BUCKET_NAME = var.bucket_name
    }
  }

  timeout = 10
}

# Permission for S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamo_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

# S3 bucket notification to trigger Lambda on object creation
resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.dynamo_trigger.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invocation]
}
