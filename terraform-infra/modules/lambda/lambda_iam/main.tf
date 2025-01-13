# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExecRole"

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

# IAM Policy for Lambda (expanded for additional permissions)
resource "aws_iam_policy" "lambda_exec_policy" {
  name = "LambdaExecPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = var.image_store_bucket_arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "${var.image_store_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

// Basic Lambda execution policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_exec_attach_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
