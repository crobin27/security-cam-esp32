import os
import json
import base64
import boto3
from datetime import datetime

# Environment variable for the S3 bucket
BUCKET_NAME = os.environ['IMAGE_STORE_BUCKET']
s3 = boto3.client('s3')
def create_bmp_header(width, height, image_data, bits_per_pixel=24):
    if bits_per_pixel not in (16, 24):
        raise ValueError("Only 16-bit (RGB565) and 24-bit (RGB888) BMP formats are supported.")

    # Calculate row padding for BMP format (must be a multiple of 4 bytes)
    row_stride = (width * (bits_per_pixel // 8) + 3) & ~3
    image_size = row_stride * height  # Total pixel data size

    file_size = 54 + image_size  # 54 bytes header + pixel data
    header = bytearray(54)

    # BMP file header (14 bytes)
    header[0:2] = b'BM'                            # Signature
    header[2:6] = file_size.to_bytes(4, 'little')  # File size
    header[6:8] = (0).to_bytes(2, 'little')        # Reserved
    header[8:10] = (0).to_bytes(2, 'little')       # Reserved
    header[10:14] = (54).to_bytes(4, 'little')     # Offset to pixel array

    # DIB header (40 bytes)
    header[14:18] = (40).to_bytes(4, 'little')     # DIB header size
    header[18:22] = width.to_bytes(4, 'little')    # Image width
    header[22:26] = (-height).to_bytes(4, 'little', signed=True)  # Flip the image vertically
    header[26:28] = (1).to_bytes(2, 'little')      # Number of color planes
    header[28:30] = bits_per_pixel.to_bytes(2, 'little')  # Bits per pixel
    header[30:34] = (0).to_bytes(4, 'little')      # No compression
    header[34:38] = image_size.to_bytes(4, 'little')  # Image data size
    header[38:42] = (2835).to_bytes(4, 'little')   # Horizontal resolution (72 DPI)
    header[42:46] = (2835).to_bytes(4, 'little')   # Vertical resolution (72 DPI)
    header[46:50] = (0).to_bytes(4, 'little')      # Number of colors in the palette
    header[50:54] = (0).to_bytes(4, 'little')      # Important colors

    # Convert 8-bit grayscale to 24-bit RGB
    if bits_per_pixel == 24:
        new_image_data = bytearray()
        for pixel in image_data:
            new_image_data.extend((pixel, pixel, pixel))  # Convert grayscale to RGB
    elif bits_per_pixel == 16:
        new_image_data = bytearray()
        for pixel in image_data:
            r = (pixel >> 3) & 0x1F
            g = (pixel >> 2) & 0x3F
            b = (pixel >> 3) & 0x1F
            rgb565 = (r << 11) | (g << 5) | b
            new_image_data.extend(rgb565.to_bytes(2, 'little'))  # Convert to RGB565

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
        content_type = ""
        if "Content-Type" in event["headers"] and event["headers"]["Content-Type"] == "image/jpeg":
            filename = f"photo_{timestamp_str}.jpeg"
            content_type = "image/jpeg"
        elif "Content-Type" in event["headers"] and event["headers"]["Content-Type"] == "image/bmp":
            print("Processing BMP image...")
            width, height = 320, 240  # Update with actual width/height
            image_data = create_bmp_header(width, height, image_data, bits_per_pixel=24)
            filename = f"photo_{timestamp_str}.bmp"
            content_type = "image/bmp"
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
