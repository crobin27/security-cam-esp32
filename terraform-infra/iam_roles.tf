# IAM Role for Lambda to access S3
resource "aws_iam_role" "lambda_role" {
  name = "PresignedURLLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy to allow Lambda to put objects in S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name   = "LambdaS3Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.images_bucket.arn}/*"  # Grants access to all objects in the bucket
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}
