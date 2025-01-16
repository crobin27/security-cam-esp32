import os
import json
import base64
import boto3
from datetime import datetime

BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']
s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        image_base64 = event["body"] 

        if event.get("isBase64Encoded", False):
            image_data = base64.b64decode(image_base64)
        else:
            image_data = image_base64.encode("utf-8")

        
        timestamp_str = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        filename = f"photo_{timestamp_str}.jpg"
        if "queryStringParameters" in event and event["queryStringParameters"]:
            filename = event["queryStringParameters"].get("filename", "default.jpg")

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