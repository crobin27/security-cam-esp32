resource "aws_iot_thing" "this" {
    name = var.thing_name
}

resource "aws_iot_certificate" "this" {
    active = true
}

resource "aws_iot_policy" "this" {
    name = "${var.thing_name}-policy"
    policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "iot:Connect",
                    "iot:Publish",
                    "iot:Subscribe",
                    "iot:Receive"
                ],
                "Resource": "*"
            }
        ]
    }
    EOF
}

resource "aws_iot_policy_attachment" "this" {
    policy = aws_iot_policy.this.name
    target      = aws_iot_certificate.this.arn
}

resource "aws_iot_thing_principal_attachment" "this" {
  thing     = aws_iot_thing.this.name
  principal = aws_iot_certificate.this.arn
}

# Add the IoT Endpoint Data Source
data "aws_iot_endpoint" "this" {
  endpoint_type = "iot:Data-ATS"
}