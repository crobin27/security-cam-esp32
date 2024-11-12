resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "lambda_s3_access_policy"
  description = "Policy for Lambda to access S3 bucket for presigned URL generation."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${module.s3_image_store.bucket_arn}",
          "${module.s3_image_store.bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the role created in `lambda-iam-role` module
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = module.lambda_iam_role.role_name
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
}
