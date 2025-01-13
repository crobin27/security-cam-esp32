import boto3
import os
import json

# Initialize S3 client
s3 = boto3.client('s3')

# Get the S3 bucket name from environment variables
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']

def lambda_handler(event, context):
    try:
        # Parse the filename from the incoming event
        body = json.loads(event.get('body', '{}'))
        filename = body.get('filename', 'default.jpg')

        # Validate filename
        if not filename:
            raise ValueError("Filename is required.")

        # Generate a presigned URL for uploading the file
        presigned_url = s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': BUCKET_NAME,
                'Key': filename,
                'ContentType': 'image/jpeg'  # Expected content type
            },
            ExpiresIn=3600  # URL valid for 1 hour
        )

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"upload_url": presigned_url})
        }
    except Exception as e:
        print(f"Error generating presigned URL: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
