output "bucket_arn" {
  value = aws_s3_bucket.image_store.arn
}

output "bucket_id" {
  value = aws_s3_bucket.image_store.id
}

output "bucket_name" {
  value = aws_s3_bucket.image_store.bucket
}
