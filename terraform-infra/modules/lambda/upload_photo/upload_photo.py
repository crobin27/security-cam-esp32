import os
import json
import base64
import boto3
from datetime import datetime

# Environment variable for the S3 bucket
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']
s3 = boto3.client('s3')
def create_bmp_header(width, height, image_data, bits_per_pixel=24):
    row_stride = (width * (bits_per_pixel // 8) + 3) & ~3
    image_size = row_stride * height
    file_size = 54 + image_size
    header = bytearray(54)

    # BMP Header
    header[0:2] = b'BM'
    header[2:6] = file_size.to_bytes(4, 'little')
    header[10:14] = (54).to_bytes(4, 'little')
    header[14:18] = (40).to_bytes(4, 'little')
    header[18:22] = width.to_bytes(4, 'little')
    header[22:26] = (-height).to_bytes(4, 'little', signed=True)
    header[26:28] = (1).to_bytes(2, 'little')
    header[28:30] = bits_per_pixel.to_bytes(2, 'little')
    header[34:38] = image_size.to_bytes(4, 'little')

    # Convert grayscale to RGB and add padding
    new_image_data = bytearray()
    padding = (4 - (width * 3) % 4) % 4  # Padding for 4-byte alignment

    for row in range(height):
        for col in range(width):
            pixel = image_data[row * width + col]
            new_image_data.extend((pixel, pixel, pixel))  # Grayscale to RGB
        new_image_data.extend(b'\x00' * padding)  # Add padding at end of row

    return header + new_image_data


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

        # depending on the "Content-Type" in the header, the filename may be different
        # Handle both 'Content-Type' and 'content-type' keys
        content_type = event["headers"].get("Content-Type") or event["headers"].get("content-type")

        if content_type == "image/jpeg":
            filename = f"photo_{timestamp_str}.jpeg"
            content_type = "image/jpeg"
        elif content_type == "image/bmp":
            print("Processing BMP image...")
            width, height = 160, 120  # Update with actual width/height
            image_data = create_bmp_header(width, height, image_data, bits_per_pixel=24)
            filename = f"photo_{timestamp_str}.bmp"
            content_type = "image/bmp"
        else: 
             print("Received headers:", json.dumps(event.get("headers", {})))
             raise ValueError(f"Unsupported Content-Type: {event['headers'].get('Content-Type', 'unknown')}")
        
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
            ContentType=content_type
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
