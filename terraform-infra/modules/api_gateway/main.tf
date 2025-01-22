# API Gateway REST API
resource "aws_api_gateway_rest_api" "esp32_api" {
  name               = var.api_name
  description        = var.api_description
  binary_media_types = ["image/jpeg", "image/png", "image/jpg"]
}

# Deployment for the API
resource "aws_api_gateway_deployment" "esp32_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  stage_name  = var.stage_name

  depends_on = [aws_api_gateway_integration.display_photos_integration,
    aws_api_gateway_integration.upload_photo_integration,
  aws_api_gateway_integration.take_photo_integration]
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
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_display_photos}/invocations"
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

# Child resource: /upload-photo/{folder}
resource "aws_api_gateway_resource" "upload_photo_folder" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_resource.upload_photo.id
  path_part   = "{folder}" # Valid greedy path variable
}

# POST method for /upload-image/{folder}
resource "aws_api_gateway_method" "upload_photo_folder_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.upload_photo_folder.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda function for /upload-image/{folder}
resource "aws_api_gateway_integration" "upload_photo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
 resource_id             = aws_api_gateway_resource.upload_photo_folder.id
  http_method             = aws_api_gateway_method.upload_photo_folder_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_upload_photo}/invocations"
}


# Lambda permission for API Gateway
resource "aws_lambda_permission" "lambda_upload_photo_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_upload_photo
  principal     = "apigateway.amazonaws.com"

  # Specify the source ARN for the API Gateway stage
   source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.esp32_api.id}/*/${aws_api_gateway_method.upload_photo_folder_method.http_method}/${aws_api_gateway_resource.upload_photo.path_part}/${aws_api_gateway_resource.upload_photo_folder.path_part}"
}

# Root resource: /take-photo
resource "aws_api_gateway_resource" "take_photo" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "take-photo"
}

# POST method for /take-photo
resource "aws_api_gateway_method" "take_photo_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.take_photo.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda function for /take-photo
resource "aws_api_gateway_integration" "take_photo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
  resource_id             = aws_api_gateway_resource.take_photo.id
  http_method             = aws_api_gateway_method.take_photo_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_take_photo}/invocations"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "lambda_take_photo_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_take_photo
  principal     = "apigateway.amazonaws.com"

  # Specify the source ARN for the API Gateway stage
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.esp32_api.id}/*/${aws_api_gateway_method.take_photo_method.http_method}/${aws_api_gateway_resource.take_photo.path_part}"
}