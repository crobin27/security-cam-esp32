import os
import json
import base64
import boto3
from datetime import datetime

# Environment variable for the S3 bucket
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']
s3 = boto3.client('s3')
def create_bmp_header(width, height, image_data):
    """
    Create a BMP header for grayscale image data.
    """
    file_size = 54 + len(image_data)  # 54 bytes for the header + image data
    header = bytearray(54)

    # BMP file header (14 bytes)
    header[0:2] = b'BM'                          # Signature
    header[2:6] = file_size.to_bytes(4, 'little')  # File size
    header[6:8] = (0).to_bytes(2, 'little')       # Reserved
    header[8:10] = (0).to_bytes(2, 'little')      # Reserved
    header[10:14] = (54).to_bytes(4, 'little')    # Offset to pixel array

    # DIB header (40 bytes)
    header[14:18] = (40).to_bytes(4, 'little')    # DIB header size
    header[18:22] = width.to_bytes(4, 'little')   # Image width

    # For a "top-down" BMP, manually compute two's complement for negative height
    if height < 0:
        height = (1 << 32) + height  # Compute two's complement for the negative value
    header[22:26] = height.to_bytes(4, 'little')  # Image height

    header[26:28] = (1).to_bytes(2, 'little')     # Number of color planes
    header[28:30] = (8).to_bytes(2, 'little')     # Bits per pixel (8 for grayscale)
    header[30:34] = (0).to_bytes(4, 'little')     # No compression
    header[34:38] = len(image_data).to_bytes(4, 'little')  # Image data size
    header[38:42] = (2835).to_bytes(4, 'little')  # Horizontal resolution (72 DPI)
    header[42:46] = (2835).to_bytes(4, 'little')  # Vertical resolution (72 DPI)
    header[46:50] = (256).to_bytes(4, 'little')   # Number of colors in the palette
    header[50:54] = (0).to_bytes(4, 'little')     # Important colors

    # Grayscale color palette (256 entries)
    palette = bytearray()
    for i in range(256):
        palette.extend((i, i, i, 0))  # R, G, B, Reserved

    return header + palette + image_data

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
        content_type = ""
        if "Content-Type" in event["headers"] and event["headers"]["Content-Type"] == "image/jpeg":
            filename = f"photo_{timestamp_str}.jpeg"
            content_type = "image/jpeg"
        elif "Content-Type" in event["headers"] and event["headers"]["Content-Type"] == "image/bmp":
            filename = f"photo_{timestamp_str}.bmp"
            content_type = "image/bmp"
            # Add BMP header to raw image data
            width = 160  # Replace with actual width
            height = 120  # Replace with actual height
            image_data = create_bmp_header(width, height, image_data)
        else: 
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
