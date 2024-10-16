#ifndef MOTION_DETECTION_H
#define MOTION_DETECTION_H

#include <inttypes.h>  // Include for the PRIu32 macro

#include "aws_upload.h"
#include "camera.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// Define constants
#define MOTION_THRESHOLD 100000  // Threshold for motion detection
#define NUM_PHOTOS_ON_MOTION \
  5                           // Number of photos to capture on motion detection
#define CAPTURE_INTERVAL 500  // Time (ms) between photo captures after motion

// Function declarations

// Function to detect motion by comparing two images
bool detect_motion(camera_fb_t *img1, camera_fb_t *img2);

// Function to capture multiple photos and upload them when motion is detected
void capture_and_upload_photos();

// Motion detection task to run periodically and check for motion
void motion_detection_task(void *pvParameters);

// Function to start the motion detection task
void start_motion_detection_task();

#endif  // MOTION_DETECTION_H
