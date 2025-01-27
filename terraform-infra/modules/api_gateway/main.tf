# API Gateway REST API
resource "aws_api_gateway_rest_api" "esp32_api" {
  name               = var.api_name
  description        = var.api_description
  binary_media_types = ["image/jpeg", "image/png", "image/jpg", "image/bmp"]
}

# Deployment for the API
resource "aws_api_gateway_deployment" "esp32_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  stage_name  = var.stage_name

  depends_on = [aws_api_gateway_integration.display_photos_integration,
    aws_api_gateway_integration.upload_photo_integration,
  aws_api_gateway_integration.iot_command_integration]
}

# Root resource: /display-photos
resource "aws_api_gateway_resource" "display_photos" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "display-photos"
}

# Child resource: /display-photos/{folder}
resource "aws_api_gateway_resource" "display_photos_folder" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_resource.display_photos.id
  path_part   = "{folder}" # Valid greedy path variable
}

# GET method for /display-photos
resource "aws_api_gateway_method" "display_photos_folder_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.display_photos_folder.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration with Lambda function for /display-photos
resource "aws_api_gateway_integration" "display_photos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
  resource_id             = aws_api_gateway_resource.display_photos_folder.id
  http_method             = aws_api_gateway_method.display_photos_folder_method.http_method
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

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.esp32_api.id}/*/${aws_api_gateway_method.display_photos_folder_method.http_method}/${aws_api_gateway_resource.display_photos.path_part}/${aws_api_gateway_resource.display_photos_folder.path_part}"
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

# Root resource: /iot_message
resource "aws_api_gateway_resource" "publish_iot_message" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "iot_message"
}

# child resource: /iot_message/{command}
resource "aws_api_gateway_resource" "iot_command" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_resource.publish_iot_message.id
  path_part   = "{command}"
}

# POST method for /iot-photo
resource "aws_api_gateway_method" "iot_command_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.iot_command.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda function for /iot_command
resource "aws_api_gateway_integration" "iot_command_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
  resource_id             = aws_api_gateway_resource.iot_command.id
  http_method             = aws_api_gateway_method.iot_command_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_iot_command}/invocations"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "lambda_iot_command_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_iot_command
  principal     = "apigateway.amazonaws.com"

  # Specify the source ARN for the API Gateway stage
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.esp32_api.id}/*/${aws_api_gateway_method.iot_command_method.http_method}/${aws_api_gateway_resource.publish_iot_message.path_part}/${aws_api_gateway_resource.iot_command.path_part}"
}