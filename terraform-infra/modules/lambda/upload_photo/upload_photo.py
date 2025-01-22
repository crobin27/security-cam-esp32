import os
import json
import base64
import boto3
from datetime import datetime

# Environment variable for the S3 bucket
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']
s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("DEBUG EVENT:", json.dumps(event))  # Debugging information

    try:
        # Extract body and decode if base64 encoded
        body_b64 = event["body"]
        if event.get("isBase64Encoded", False):
            # Convert from base64 to raw bytes
            image_data = base64.b64decode(body_b64)
        else:
            image_data = body_b64.encode("utf-8")

        # Extract folder name from the path
        path = event["path"]  # Example: "/upload-photo/manual-capture-images/"
        folder_name = path.strip("/").split("/")[-1]  # Extracts "manual-capture-images"

        # Generate a timestamped filename
        timestamp_str = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        filename = f"photo_{timestamp_str}.jpeg"

        # If a query parameter specifies a filename, use it instead
        if "queryStringParameters" in event and event["queryStringParameters"]:
            filename = event["queryStringParameters"].get("filename", filename)

        # Combine folder name and filename for the S3 key
        s3_key = f"{folder_name}/{filename}"

        # Upload to S3
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=s3_key,
            Body=image_data,
            ContentType="image/jpeg"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Image uploaded successfully!",
                "file": s3_key
            })
        }

    except Exception as e:
        print(e)  # Log the exception
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
