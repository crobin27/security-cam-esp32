output "certificate_pem" {
  value = aws_iot_certificate.this.certificate_pem
}

output "private_key" {
  value = aws_iot_certificate.this.private_key
  sensitive = true
}

output "certificate_arn" {
  value = aws_iot_certificate.this.arn
}

output "iot_endpoint" {
  value = data.aws_iot_endpoint.this.endpoint_address
}