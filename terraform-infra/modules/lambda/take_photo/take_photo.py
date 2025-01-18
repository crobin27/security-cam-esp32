import os
import json
import base64
import boto3
from datetime import datetime

# AWS IoT Data client
iot_client = boto3.client("iot-data", region_name=os.environ["AWS_REGION"])

# The IoT topic to publish the message to
IOT_TOPIC = os.environ.get("IOT_TOPIC", "esp32/take_picture")

def lambda_handler(event, context):
    try:
        # Log the incoming event for debugging
        print(f"Received event: {json.dumps(event)}")
        
        # Construct the message to send to the ESP32
        message = {
            "command": "take_picture",
            "timestamp": event.get("requestContext", {}).get("requestTimeEpoch", 0)
        }

        # Publish the message to the specified IoT topic
        response = iot_client.publish(
            topic=IOT_TOPIC,
            qos=1,  # Quality of Service level 1 (ensures delivery at least once)
            payload=json.dumps(message)
        )

        # Log the response for debugging
        print(f"IoT Publish Response: {response}")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Command to take a picture sent successfully",
                "iot_topic": IOT_TOPIC
            }),
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }