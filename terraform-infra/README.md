# Terraform Infrastructure

This folder contains the Terraform configuration and modules for provisioning the backend infrastructure of the Security Cam ESP32 project. It is responsible for setting up and managing all the cloud resources required for the application, using Infrastructure as Code (IaC) best practices.

## Overview

The `terraform-infra` directory is divided into modular components, each representing a specific part of the infrastructure. The project is designed with scalability, security, and automation in mind. These modules demonstrate advanced knowledge and skills in infrastructure management, including:

- **AWS IAM Policies**: Implemented least privilege policies to secure resources.
- **Serverless Architecture**: Designed and automated Lambda functions for seamless backend logic.
- **API Gateway**: Configured a RESTful API for communication between the ESP32 and cloud services.
- **S3 Buckets**: Provisioned buckets for:
  - Hosting the web frontend (`s3_frontend`).
  - Storing images captured by the ESP32 (`s3_image_store`).
- **IoT Integration**: Set up AWS IoT Core for secure device communication.
- **Python Automation**: Wrote Python scripts for Lambda to handle serverless workflows, including:
  - Generating pre-signed S3 URLs for secure image upload.
  - Managing DynamoDB entries for metadata storage.
- **Modular Terraform**: Leveraged reusable modules to maintain clean and efficient infrastructure code.

## Folder Structure

Below is the folder structure of the `terraform-infra/modules` directory:

```
modules/
├── api_gateway
├── iot
├── lambda
├── s3_frontend
└── s3_image_store
```

### Module Descriptions

- **`api_gateway`**: Defines and deploys the API Gateway configuration for the project. This serves as the entry point for all communication between the ESP32 devices and the backend services.
- **`iot`**: Configures AWS IoT Core, including Thing Policies and Certificates, enabling secure communication for the ESP32 device.
- **`lambda`**: Sets up AWS Lambda functions written in Python. These functions automate backend tasks such as S3 image upload handling and database entry creation.
- **`s3_frontend`**: Provisions an S3 bucket for hosting the web frontend, complete with website hosting settings and appropriate bucket policies.
- **`s3_image_store`**: Configures an S3 bucket for storing captured images, with fine-grained access controls.

## Skills and Concepts Learned

- **Infrastructure as Code (IaC)**: Used Terraform to automate the creation and management of AWS resources.
- **AWS IAM and Security**: Gained expertise in crafting least privilege policies to protect resources and enforce security best practices.
- **Serverless Computing**: Mastered Lambda configuration and integration for automated, event-driven workflows.
- **Modular Design**: Learned how to write reusable and scalable Terraform modules for managing complex cloud infrastructure.
- **Python Scripting**: Developed Lambda functions to handle key backend processes efficiently.
- **Cloud Storage and Hosting**: Utilized S3 for static site hosting and secure file storage.
- **Device Integration**: Gained knowledge in IoT protocols and how to securely integrate devices with AWS IoT Core.

## Future Enhancements

While the current setup is fully functional, future improvements could include:

- Adding monitoring and alerting for backend resources (e.g., AWS CloudWatch).
- Implementing CI/CD pipelines for infrastructure deployment and updates.
- Exploring cost optimization strategies for AWS resources.

---

This directory showcases my ability to architect and manage cloud infrastructure using Terraform, while demonstrating a solid understanding of cloud security and serverless workflows.
