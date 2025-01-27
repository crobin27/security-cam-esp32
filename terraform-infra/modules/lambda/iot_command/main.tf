# Lambda Function
resource "aws_lambda_function" "publish_iot_message" {
  filename         = "${path.module}/iot_command.zip" # Path to the zipped Lambda code
  function_name    = "IoTCommandHandler"
  handler          = "iot_command.lambda_handler"
  runtime          = "python3.9"
  role             = var.lambda_iam_role_arn
  source_code_hash = filebase64sha256("${path.module}/iot_command.zip")


  environment {
    variables = {
      IOT_TAKE_PICTURE_TOPIC = "esp32/take_picture",
      IOT_MOTION_DETECTION_TOPIC = "esp32/motion_detection"
    }
  }
  tags = {
    Name = "IoTCommandLambda"
  }
}