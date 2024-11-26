output "dynamo_table_name" {
  description = "Name of the DynamoDB table for image metadata"
  value       = aws_dynamodb_table.image_metadata.name
}

output "dynamo_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.image_metadata.arn
}