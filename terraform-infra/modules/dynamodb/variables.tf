variable "dynamo_table_name" {
    type = string
    description = "The name of the DynamoDB table"
    default = "dynamo-metadata"
}