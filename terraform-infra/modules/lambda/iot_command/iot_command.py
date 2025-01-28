import os
import json
import boto3

# AWS IoT Data client
iot_client = boto3.client("iot-data", region_name=os.environ["AWS_REGION"])

# The IoT topics to publish the message to
IOT_TAKE_PICTURE_TOPIC = os.environ.get("IOT_TAKE_PICTURE_TOPIC", "esp32/take_picture")
IOT_MOTION_DETECTION_TOPIC = os.environ.get("IOT_MOTION_DETECTION_TOPIC", "esp32/motion_detection")

def lambda_handler(event, context):
    try:
        print(f"DEBUG: Received event: {json.dumps(event)}")

        # Extract the command from pathParameters
        command = event.get("pathParameters", {}).get("command", None)
        print(f"DEBUG: Extracted command: {command}")

        if not command:
            print("DEBUG: Command parameter is missing.")
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Command parameter is required."})
            }

        # Determine the topic based on the command
        if command == "take_picture":
            topic = IOT_TAKE_PICTURE_TOPIC
        elif command == "motion_detection":
            topic = IOT_MOTION_DETECTION_TOPIC
        else:
            print(f"DEBUG: Unsupported command: {command}")
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": f"Unsupported command: {command}"})
            }

        print(f"DEBUG: Selected topic: {topic}")

        # Construct the message to send to the ESP32
        message = {
            "command": command,
            "timestamp": event.get("requestContext", {}).get("requestTimeEpoch", 0)
        }
        print(f"DEBUG: Constructed message: {message}")

        # Publish the message to the specified IoT topic
        response = iot_client.publish(
            topic=topic,
            qos=1,
            payload=json.dumps(message)
        )
        print(f"DEBUG: IoT Publish Response: {response}")

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": f"Command '{command}' sent successfully",
                "iot_topic": topic
            }),
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)}),
        }