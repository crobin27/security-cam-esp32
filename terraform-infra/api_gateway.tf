
resource "aws_apigatewayv2_api" "upload_api" {
  name          = "ImageUploadAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "s3_integration" {
  api_id             = aws_apigatewayv2_api.upload_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_s3_bucket.images_bucket.arn
  integration_method = "PUT"
}
