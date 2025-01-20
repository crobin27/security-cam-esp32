#include <stdio.h>
#include <string.h>

#include "aws_upload.h" // Include the AWS upload header
#include "camera.h"     // Include the camera task header
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"
#include "freertos/task.h"
#include "wifi_connect.h" // Include the Wi-Fi connection header

#include "aws_iot.h"

static const char *TAG = "App_Main";
// MQTT Broker URI
#define MQTT_BROKER_URI CONFIG_AWS_IOT_ENDPOINT // Define this in sdkconfig

// Queue for inter-task communication
QueueHandle_t commandQueue;

// Task handles
TaskHandle_t cameraTaskHandle = NULL;
TaskHandle_t mqttTaskHandle = NULL;

void camera_task(void *param) {
  ESP_LOGI(TAG, "Camera Task Started on Core %d", xPortGetCoreID());

  char command[32];
  while (true) {
    // Wait for a command from the queue
    if (xQueueReceive(commandQueue, command, portMAX_DELAY)) {
      ESP_LOGI(TAG, "Received command: %s", command);

      if (strcmp(command, "take_picture") == 0) {
        // Capture image
        camera_fb_t *fb = capture_image();
        if (fb) {
          ESP_LOGI(TAG, "Image captured. Uploading...");
          upload_image_to_s3(fb->buf, fb->len);
          ESP_LOGI(TAG, "Image uploaded successfully.");
          release_image(fb);
        } else {
          ESP_LOGE(TAG, "Failed to capture image.");
        }
      }
    }
  }
}

// MQTT task (Core 0)
void mqtt_task(void *param) {
  ESP_LOGI(TAG, "MQTT Task Started on Core %d", xPortGetCoreID());

  initialize_mqtt(CONFIG_AWS_IOT_ENDPOINT, commandQueue);

  while (true) {
    vTaskDelay(pdMS_TO_TICKS(1000)); // Periodically check MQTT status
  }
}

void app_main() {
  ESP_LOGI(TAG, "ESP32 Starting Up");

  // Initialize Wi-Fi
  initialize_wifi();

  // Initialize camera
  if (init_camera() != ESP_OK) {
    ESP_LOGE(TAG, "Camera initialization failed. Stopping.");
    return;
  }

  // Create a queue for inter-task communication
  commandQueue = xQueueCreate(5, sizeof(char) * 32);
  if (!commandQueue) {
    ESP_LOGE(TAG, "Failed to create command queue.");
    return;
  }

  // Create tasks and pin them to specific cores
  xTaskCreatePinnedToCore(camera_task, "Camera Task", 4096, NULL, 1,
                          &cameraTaskHandle, 1); // Core 1
  xTaskCreatePinnedToCore(mqtt_task, "MQTT Task", 4096, NULL, 1,
                          &mqttTaskHandle, 0); // Core 0

  ESP_LOGI(TAG, "Tasks created successfully. Main loop running on Core %d",
           xPortGetCoreID());
}