output "table_name" {
  value = aws_dynamodb_table.image_metadata_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.image_metadata_table.arn
}
