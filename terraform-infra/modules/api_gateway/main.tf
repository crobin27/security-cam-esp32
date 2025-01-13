# API Gateway REST API
resource "aws_api_gateway_rest_api" "esp32_api" {
  name        = var.api_name
  description = var.api_description
}

# Deployment for the API
resource "aws_api_gateway_deployment" "esp32_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  stage_name  = var.stage_name

  depends_on = [aws_api_gateway_integration.display_photos_integration,
                aws_api_gateway_integration.upload_photo_integration]
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
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_display_photos}/invocations"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "lambda_display_photos_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_display_photos
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.esp32_api.id}/*/${aws_api_gateway_method.display_photos_method.http_method}/${aws_api_gateway_resource.display_photos.path_part}"
}

# Root resource: /upload-photo
resource "aws_api_gateway_resource" "upload_photo" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "upload-photo"
}

# POST method for /upload-image
resource "aws_api_gateway_method" "upload_photo_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.upload_photo.id
  http_method   = "POST"
  authorization = "NONE" 
}

# Integration with Lambda function for /upload-image
resource "aws_api_gateway_integration" "upload_photo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
  resource_id             = aws_api_gateway_resource.upload_photo.id
  http_method             = aws_api_gateway_method.upload_photo_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_upload_photo}/invocations"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "lambda_upload_photo_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_upload_photo
  principal     = "apigateway.amazonaws.com"

  # Specify the source ARN for the API Gateway stage
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.esp32_api.id}/*/${aws_api_gateway_method.upload_photo_method.http_method}/${aws_api_gateway_resource.upload_photo.path_part}"
}


