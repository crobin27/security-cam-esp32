# ESP32 Trail Camera Project

## Overview
This project is a trail camera system built using the ESP32 microcontroller. The camera is designed to capture images upon movement detection or when triggered, then upload the images to an Amazon S3 bucket using secure HTTPS connections. The system is optimized for low power consumption, making it ideal for remote monitoring in natural environments. The images can be viewed anywhere from an Android application using Kotlin, this repository holds the ESP32 components.

## Features
- **Wi-Fi Connectivity**: Automatically connects to a specified Wi-Fi network upon startup (setup in menuconfig, see Kconfig file).
- **AWS Integration**: Uploads captured images to an Amazon S3 bucket using a secure HTTPS connection and API Gateway.
- **Customizable Image Capture**: Configurable to take images at specific intervals or based on external triggers.
- **FreeRTOS Implementation**: Tasks are handled using the FreeRTOS operating system to ensure efficient multitasking and system stability.
- **Secure HTTPS Communication**: Utilizes root CA certificates for secure communication with AWS services.

## Project Structure
```
/ESP32 Projects/Trail Cam/
├── main/
│   ├── camera_task.c          # Handles camera initialization and image capture
│   ├── camera_task.h          # Header file for camera task functionality
│   ├── wifi_connect.c         # Manages Wi-Fi connection and event handling
│   ├── wifi_connect.h         # Header file for Wi-Fi management
│   ├── aws_upload.c           # Handles file uploads to AWS S3 using HTTPS
│   ├── aws_upload.h           # Header file for AWS upload functionality
│   └── main.c                 # Entry point for the application
├── components/                # Contains external libraries and dependencies
├── sdkconfig                  # Configuration file for the ESP32 project
├── sdkconfig.old              # Backup of the previous configuration
├── CMakeLists.txt             # CMake build configuration
└── README.md                  # Project overview and documentation (this file)
```

## Dependencies
This project relies on the ESP-IDF framework provided by Espressif Systems. Make sure you have the following installed:
- **ESP-IDF v5.3.1** or later
- **Amazon Root CA Certificate** for HTTPS communication with AWS
- AWS IAM role configured for S3 access

## Getting Started
To get this project running on your ESP32 device, follow these steps:
1. **Set Up ESP-IDF**: Ensure you have ESP-IDF installed on your development machine.
2. **Configure Wi-Fi Credentials**: Open the `menuconfig` and set your Wi-Fi SSID and password under `Wi-Fi Configuration`.
3. **AWS Setup**: Ensure your AWS S3 bucket and IAM roles are properly configured.
4. **Build and Flash**: Use the following commands to build and flash the project to your ESP32:
   ```bash
   idf.py build
   idf.py flash
   ```
5. **Monitor the Device**: To see the debug logs and monitor the device, run:
   ```bash
   idf.py monitor
   ```

## Key Features Implemented
- **Wi-Fi Connection Management**: Automatically connects to the network and handles reconnection attempts.
- **AWS Upload Task**: Waits for a successful Wi-Fi connection before uploading files to S3.
- **Camera Initialization**: Uses the ESP32 camera module to capture images with configurable settings.
- **Semaphore-Based Synchronization**: Ensures that tasks only execute once the Wi-Fi connection is established.

## Future Improvements
- **Motion Detection**: Implementing PIR sensor support for motion-triggered image capture.
- **Low Power Mode**: Reducing power consumption when the camera is idle.
- **Enhanced Error Handling**: Better debugging and error-handling features for communication failures.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
