resource "aws_dynamodb_table" "image_metadata" {
  name           = var.dynamo_table_name
  billing_mode   = "PAY_PER_REQUEST" # Cost-effective for variable workloads
  hash_key       = "ImageID"         # Primary key
  stream_enabled = true              # Optional: Enable streams for event triggers
  stream_view_type = "NEW_IMAGE"     # Track only new items in streams

  attribute {
    name = "ImageID"
    type = "S" # String
  }

  # Optional: Secondary Index for querying by timestamp
  global_secondary_index {
    name            = "TimestampIndex"
    hash_key        = "Timestamp"
    projection_type = "ALL"

    write_capacity = 1
    read_capacity  = 1
  }

  attribute {
    name = "Timestamp"
    type = "S" # String
  }

  tags = {
    Name        = "Image Metadata Table"
  }
}