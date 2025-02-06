import boto3
import os
import json

s3 = boto3.client('s3')

BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']

def lambda_handler(event, context):
    try:
        # Extract the folder from the path parameter
        folder = event["pathParameters"].get("folder", None)
        if not folder:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Folder parameter is required."})
            }

        # Determine the number of files to fetch based on the folder
        max_files = 5 if folder == "manual-capture-images" else 3 if folder == "motion-detection-images" else 0
        if max_files == 0:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": f"Unsupported folder: {folder}"})
            }

        # List objects in the specified folder
        response = s3.list_objects_v2(Bucket=BUCKET_NAME, Prefix=f"{folder}/")
        if "Contents" not in response:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": f"No images found in folder: {folder}"})
            }

        # Sort the files by LastModified in descending order and get the required number
        files = sorted(response["Contents"], key=lambda x: x["LastModified"], reverse=True)[:max_files]

        # Generate presigned URLs for the images
        photo_urls = [
            s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': BUCKET_NAME, 'Key': file['Key']},
                ExpiresIn=3600  # 1 hour expiration
            )
            for file in files
        ]

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"photos": photo_urls})
        }
    except Exception as e:
        print(f"Error retrieving files: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
