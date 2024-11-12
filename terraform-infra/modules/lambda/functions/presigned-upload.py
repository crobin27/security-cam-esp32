import boto3
import os
import json
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = os.environ.get("BUCKET_NAME")
    object_name = event.get("queryStringParameters", {}).get("file_name")
    expiration = int(os.environ.get("URL_EXPIRATION", 3600))  # URL expiration in seconds

    if not object_name:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "file_name query parameter is required"})
        }

    try:
        # Generate a presigned URL for the S3 put_object operation
        response = s3_client.generate_presigned_url(
            'put_object',
            Params={'Bucket': bucket_name, 'Key': object_name},
            ExpiresIn=expiration
        )
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({"upload_url": response})
    }