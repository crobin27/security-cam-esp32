resource "aws_dynamodb_table" "image_metadata_table" {
  name         = var.table_name          # Use a variable for table name
  billing_mode = "PAY_PER_REQUEST"       # Set billing to pay-per-request for flexibility
  hash_key     = "unique_id"             # Primary partition key

  # Define attributes: primary key, and non-key attributes
  attribute {
    name = "unique_id"
    type = "S"  # String
  }

  # Tags for easy identification (optional)
  tags = {
    Environment = "Development"
    Project     = "ESP32_Image_Upload"
  }
}
