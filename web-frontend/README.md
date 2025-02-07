# Web Frontend for Security Cam ESP32

This directory contains the simple web interface for the Security Cam ESP32 project. The web frontend allows users to view captured images uploaded by the ESP32-CAM module and provides a user-friendly way to interact with the system.

## Overview

The frontend is a static web application built with HTML, CSS, and JavaScript. It connects to the S3 bucket where images are stored and dynamically displays the latest captured images. Please note that I did use AI tools to build most of this section as my fronted (HTML/JS) skills are limited.

### Features

- **Image Display**: Fetches and displays up to the last 5 images stored in the AWS S3 bucket.
- **Responsive Design**: Optimized for viewing across various screen sizes.
- **Error Handling**: Notifies users if there are issues retrieving images.

## Key Files

- **`index.html`**:
  - Provides the structure for the web application.
- **`styles.css`**:
  - Contains styling for the interface.
- **`script.js`**:
  - Fetches images from the S3 bucket and dynamically updates the UI.

## Skills Demonstrated

- Basic frontend development with HTML, CSS, and JavaScript.
- Integration with AWS S3 to fetch and display images.
- Responsive design principles for better user experience.

## Why This Section?

While this part of the project is relatively small, it demonstrates my ability to create a simple yet functional interface for IoT devices, bridging the gap between the hardware and the end user.

---

This frontend provides a lightweight and effective way to interact with the Security Cam ESP32 project.
