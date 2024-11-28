import boto3
import os
import json

# Initialize S3 client
s3 = boto3.client('s3')

# Get the S3 bucket name from environment variables
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']

def lambda_handler(event, context):
    try:
        # List objects in the S3 bucket
        response = s3.list_objects_v2(Bucket=BUCKET_NAME)

        # Get the list of files and sort them by the LastModified timestamp
        files = sorted(response.get('Contents', []), key=lambda x: x['LastModified'], reverse=True)

        # Get the last 5 files
        recent_files = files[:5]

        # Generate presigned URLs for the images
        photo_urls = [
            s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': BUCKET_NAME, 'Key': file['Key']},
                ExpiresIn=3600  # URL valid for 1 hour
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
