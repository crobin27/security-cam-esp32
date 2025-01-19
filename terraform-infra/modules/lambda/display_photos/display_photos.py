import boto3
import os
import json

s3 = boto3.client('s3')

# Get the S3 bucket name from environment variables
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']

def lambda_handler(event, context):
    try:
        response = s3.list_objects_v2(Bucket=BUCKET_NAME)

        # sort by LastModified
        files = sorted(response.get('Contents', []), key=lambda x: x['LastModified'], reverse=True)

        recent_files = files[:5]

        # Generate presigned URLs for the images
        photo_urls = [
            s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': BUCKET_NAME, 'Key': file['Key']},
                ExpiresIn=3600  
            )
            for file in recent_files
        ]

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"photos": photo_urls})
        }
    except Exception as e:
        print(f"Error retrieving files: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": {"error": str(e)}
        }