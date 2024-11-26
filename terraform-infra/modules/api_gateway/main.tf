resource "aws_api_gateway_rest_api" "esp32_api" {
  name = var.api_name
  description = "API Gateway for ESP32 Communication"
}

# Define the /connect resource
resource "aws_api_gateway_resource" "connect" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "connect"
}

# Define the /take-picture resource
resource "aws_api_gateway_resource" "take_picture" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "take-picture"
}

# Define the /display-photos resource
resource "aws_api_gateway_resource" "display_photos" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "display-photos"
}

resource "aws_api_gateway_method" "display_photos_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.display_photos.id
  http_method   = "GET"
  authorization = "NONE"
}