# API Gateway REST API
resource "aws_api_gateway_rest_api" "esp32_api" {
  name        = var.api_name
  description = var.api_description
}

# Root resource: /display-photos
resource "aws_api_gateway_resource" "display_photos" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "display-photos"
}

# GET method for /display-photos
resource "aws_api_gateway_method" "display_photos_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.display_photos.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration with Lambda function for /display-photos
resource "aws_api_gateway_integration" "display_photos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
  resource_id             = aws_api_gateway_resource.display_photos.id
  http_method             = aws_api_gateway_method.display_photos_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

# Deployment for the API
resource "aws_api_gateway_deployment" "esp32_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  stage_name  = var.stage_name

  depends_on = [aws_api_gateway_integration.display_photos_integration]
}