#include <stdio.h>

#include "aws_upload.h"   // Include the AWS upload header
#include "camera_task.h"  // Include the camera task header
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "wifi_connect.h"  // Include the Wi-Fi connection header

static const char *TAG = "App_Main";

void app_main() {
  ESP_LOGI(TAG, "ESP32 Starting Up");

  // Initialize Wi-Fi connection
  initialize_wifi();

  // Start the Camera Task
  start_camera_task();
}
