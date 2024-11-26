import json
import boto3
import os
from datetime import datetime

# Initialize clients
dynamodb = boto3.client('dynamodb')

# Get the DynamoDB table name from environment variables
DYNAMO_TABLE_NAME = os.environ.get("DYNAMO_TABLE")

def lambda_handler(event, context):
    try:
        # Log the incoming event for debugging
        print("Received event:", json.dumps(event))

        # Check if the event contains S3 records
        if 'Records' not in event:
            raise ValueError("No S3 event records found in the event")

        for record in event['Records']:
            # Ensure it's an S3 event
            if record.get('eventSource') != 'aws:s3':
                continue

            # Extract bucket name and object key from the event
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']

            # Get additional metadata (e.g., timestamp)
            timestamp = datetime.utcnow().isoformat()

            # Generate unique image ID based on object key
            image_id = object_key.split('/')[-1]

            # Construct metadata to insert into DynamoDB
            metadata = {
                'ImageID': {'S': image_id},
                'BucketName': {'S': bucket_name},
                'ObjectKey': {'S': object_key},
                'Timestamp': {'S': timestamp}
            }

            # Insert metadata into DynamoDB
            dynamodb.put_item(
                TableName=DYNAMO_TABLE_NAME,
                Item=metadata
            )

            print(f"Successfully inserted metadata for {object_key} into DynamoDB")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Metadata added to DynamoDB"})
        }

    except Exception as e:
        print(f"Error processing event: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }