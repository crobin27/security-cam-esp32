#include <stdio.h>

#include "aws_upload.h"  // Include the AWS upload header
#include "camera.h"      // Include the camera task header
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "motion_detection.h"  // Include the motion detection header
#include "wifi_connect.h"      // Include the Wi-Fi connection header

static const char *TAG = "App_Main";

void app_main() {
  ESP_LOGI(TAG, "ESP32 Starting Up");

  // Initialize Wi-Fi connection
  initialize_wifi();

  // Initialize camera
  if (init_camera() != ESP_OK) {
    ESP_LOGE(TAG, "Camera initialization failed. Stopping.");
    return;
  }

  // Start the motion detection task
  start_motion_detection_task();
}
