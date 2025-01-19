# Lambda Function
resource "aws_lambda_function" "take_photo" {
  filename         = "${path.module}/take_photo.zip" # Path to the zipped Lambda code
  function_name    = "TakePhotoHandler"
  handler          = "take_photo.lambda_handler"
  runtime          = "python3.9"
  role             = var.lambda_iam_role_arn
  source_code_hash = filebase64sha256("${path.module}/take_photo.zip")


  environment {
    variables = {
      IOT_TOPIC = "esp32/take_picture"
    }
  }
  tags = {
    Name = "TakePhotoLambda"
  }
}