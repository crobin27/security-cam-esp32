output "lambda_function_arn" {
  value = aws_lambda_function.presigned_upload.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.generate_presigned_upload_url.function_name
}