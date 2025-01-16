#include <stdio.h>

#include "aws_upload.h"  // Include the AWS upload header
#include "camera.h"      // Include the camera task header
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
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

  // give 3 seconds heads up before capturing an image
  for (int i = 0; i < 3; i++) {
    vTaskDelay(1000 / portTICK_PERIOD_MS);
    ESP_LOGI(TAG, "Capturing image in %d seconds", 3 - i);
  }
  camera_fb_t *fb = NULL;
  fb = capture_image();
  if (fb == NULL) {
    ESP_LOGE(TAG, "Camera capture failed. Stopping.");
    return;
  }

  // Upload image to S3
  upload_image_to_s3(fb->buf, fb->len);
  // log the image size and data 
  ESP_LOGI(TAG, "Image size: %d bytes", fb->len);
  ESP_LOGI(TAG, "Image data: %p", fb->buf);

  // Release the buffer back to the camera driver
  release_image(fb);
}
