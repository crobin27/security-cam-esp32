output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.esp32_api.id
}

output "api_gateway_url" {
  description = "URL of the deployed API Gateway"
  value       = aws_api_gateway_rest_api.esp32_api.execution_arn
}