# Lambda Function
resource "aws_lambda_function" "display_photos" {
  filename         = "${path.module}/display_photos.zip" # Path to the zipped Lambda code
  function_name    = "DisplayPhotosHandler"
  handler          = "display_photos.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      IMAGE_STORE_BUCKET = var.image_store_bucket
    }
  }

  tags = {
    Name = "DisplayPhotosLambda"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "DisplayPhotosExecRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_exec_policy" {
  name = "LambdaExecPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:ListBucket"  # Added permission for listing bucket contents
        ],
        Resource = var.image_store_bucket_arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "${var.image_store_bucket_arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}
