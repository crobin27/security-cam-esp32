# Data sources to retrieve current AWS region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM Role for Lambda function to access S3, DynamoDB, and CloudWatch Logs
resource "aws_iam_role" "lambda_dynamo_role" {
  name = "LambdaDynamoRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy to allow Lambda access to DynamoDB, S3, and CloudWatch Logs
resource "aws_iam_policy" "lambda_dynamo_policy" {
  name   = "LambdaDynamoDBPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem"],
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"  # Allows access to all log groups
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_dynamo_policy_attachment" {
  role       = aws_iam_role.lambda_dynamo_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_policy.arn
}
