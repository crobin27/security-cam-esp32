# Security Cam ESP32 Project

This repository contains all the components required to build a fully functional ESP32-based security camera system. The project integrates embedded systems, cloud infrastructure, and a web frontend to create a seamless and efficient surveillance solution. It demonstrates expertise in IoT development, cloud services, and full-stack application design.

## Overview

The Security Cam ESP32 project is designed to capture images using an ESP32-CAM module and securely upload them to AWS cloud infrastructure. The captured images can then be viewed and managed through a web interface. The project is divided into three primary sections:

1. **ESP32 (Firmware and Device Code)**: Contains the embedded C code for the ESP32-CAM module, responsible for capturing images and communicating with the cloud backend.
2. **Terraform Infrastructure**: Automates the provisioning of cloud resources needed for backend operations, including AWS IoT Core, Lambda, S3, and API Gateway.
3. **Web Frontend**: A static web application for viewing and managing the captured images stored in S3.

## Features

- **IoT Device Integration**: Captures images from an ESP32-CAM and uploads them securely to AWS.
- **Cloud Infrastructure**: Fully automated backend infrastructure provisioned with Terraform, featuring:
  - IoT Core for device management and communication.
  - Lambda functions for serverless backend workflows.
  - S3 buckets for image storage and frontend hosting.
  - API Gateway for secure communication.
- **Web Interface**: A user-friendly frontend for viewing and managing images, designed for scalability and accessibility.
- **Security**: Implements AWS IAM least privilege policies to secure all resources.
- **Event-Driven Architecture**: Uses AWS Lambda for automating backend operations like pre-signed URL generation and metadata management.

## Repository Structure

```
root/
├── esp32/                     # ESP32-CAM firmware and device code
├── terraform-infra/           # Terraform configuration for backend infrastructure
├── web-frontend/              # Web interface for managing and viewing captured images
└── README.md                  # High-level project description
```

### Folder Descriptions

- **`esp32/`**:

  - Includes the embedded firmware code for the ESP32-CAM module.
  - Handles image capture, Wi-Fi connectivity, and secure communication with the AWS backend.

- **`terraform-infra/`**:

  - Contains Terraform configuration and reusable modules for provisioning the cloud backend.
  - Automates the creation of AWS IoT Core, API Gateway, S3, and Lambda resources.

- **`web-frontend/`**:
  - A static web application hosted on S3 for viewing and managing images.
  - Built using HTML, CSS, and JavaScript, with a focus on usability and simplicity.

## Skills Demonstrated

- **Embedded Systems**: Developed firmware for the ESP32-CAM, integrating image capture and secure cloud communication.
- **Infrastructure as Code (IaC)**: Provisioned and managed AWS resources using Terraform, adhering to best practices.
- **IoT Development**: Configured AWS IoT Core to enable secure device communication.
- **Serverless Computing**: Designed event-driven workflows using AWS Lambda.
- **Web Development**: Built a responsive and intuitive static web frontend for user interaction.
- **Cloud Security**: Enforced least privilege policies with AWS IAM to secure resources.

## How It Works

1. **Image Capture**: The ESP32-CAM module captures an image and uploads it to the cloud using a pre-signed S3 URL.
2. **Backend Processing**: Lambda functions handle metadata storage and manage the backend workflows.
3. **Image Viewing**: The web frontend retrieves and displays the images from S3 for the user.

## Future Enhancements

- Add real-time notifications (e.g., email or SMS) for motion detection or new image uploads.
- Integrate machine learning for object detection or facial recognition.
- Implement advanced user management for the web frontend.

## Why This Project?

This project is a demonstration of the seamless integration of IoT devices with cloud services, showcasing skills in embedded systems, cloud architecture, and full-stack development. It highlights my ability to design and implement scalable, secure, and efficient systems that leverage modern technologies.

---

This repository serves as a portfolio project to illustrate my expertise in IoT, cloud computing, and application development. Feedback and collaboration are always welcome!
