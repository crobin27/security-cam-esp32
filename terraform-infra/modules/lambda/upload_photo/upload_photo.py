import os
import json
import base64
import boto3
from datetime import datetime

BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']
s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("DEBUG EVENT:", json.dumps(event))
    try:
        body_b64 = event["body"]
        if event.get("isBase64Encoded", False):
            # Convert from base64 to raw bytes
            image_data = base64.b64decode(body_b64)
        else:
            image_data = body_b64.encode("utf-8")  

        
        timestamp_str = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        filename = f"photo_{timestamp_str}.jpeg"
        if "queryStringParameters" in event and event["queryStringParameters"]:
            filename = event["queryStringParameters"].get("filename", "default.jpeg")

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=filename,
            Body=image_data,
            ContentType="image/jpeg"  
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Image uploaded successfully!",
                "file": filename
            })
        }

    except Exception as e:
        print(e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }