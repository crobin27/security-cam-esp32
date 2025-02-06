#include <stdio.h>
#include <string.h>

#include "aws_upload.h" // Include the AWS upload header
#include "camera.h"     // Include the camera task header
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"
#include "freertos/task.h"
#include "motion_detection.h"
#include "wifi_connect.h" // Include the Wi-Fi connection header

#include "aws_iot.h"

static const char *TAG = "App_Main";

#define MQTT_BROKER_URI CONFIG_AWS_IOT_ENDPOINT // Define this in sdkconfig

// Queue for inter-task communication
QueueHandle_t commandQueue;

// Task handles
TaskHandle_t cameraTaskHandle = NULL;
TaskHandle_t mqttTaskHandle = NULL;
TaskHandle_t motionDetectionTaskHandle = NULL;

SemaphoreHandle_t capture_mutex; // used to ensure mutual exclusion
SemaphoreHandle_t motion_detection_active;
void camera_task(void *param) {
  ESP_LOGI(TAG, "Camera Task Started on Core %d", xPortGetCoreID());

  char command[32];
  while (true) {
    if (xQueueReceive(commandQueue, command, portMAX_DELAY)) {
      ESP_LOGI(TAG, "Received command: %s", command);

      if (strcmp(command, "take_picture") == 0) {
        // Capture image
        xSemaphoreTake(capture_mutex, portMAX_DELAY);

        if (reinitialize_camera(PIXFORMAT_JPEG, FRAMESIZE_QVGA) == ESP_OK) {
          ESP_LOGI(TAG, "Camera set to color for standard capture.");
        } else {
          ESP_LOGE(TAG, "Failed to set camera to color mode.");
        }

        camera_fb_t *fb = capture_image();
        if (fb) {
          ESP_LOGI(TAG, "Image captured. Uploading...");
          upload_image_to_s3(fb->buf, fb->len, "manual-capture-images",
                             "image/jpeg");
          ESP_LOGI(TAG, "Image uploaded successfully.");
          release_image(fb);
        } else {
          ESP_LOGE(TAG, "Failed to capture image.");
        }
        xSemaphoreGive(capture_mutex);

      } else if (strcmp(command, "motion_detection") == 0) {
        // Start motion detection task if semaphore is available to start
        if (xSemaphoreTake(motion_detection_active, portMAX_DELAY) == pdTRUE) {
          ESP_LOGI(TAG, "Starting motion detection task.");

          start_motion_detection_task(&motionDetectionTaskHandle,
                                      capture_mutex);
        } else {
          ESP_LOGW(TAG, "Motion detection task is already running.");
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

  // Create a mutex for synchronization
  capture_mutex = xSemaphoreCreateMutex();
  if (!capture_mutex) {
    ESP_LOGE(TAG, "Failed to create capture mutex.");
    return;
  }

  // Create a semaphore to control motion detection task
  motion_detection_active = xSemaphoreCreateBinary();
  if (!motion_detection_active) {
    ESP_LOGE(TAG, "Failed to create motion detection semaphore.");
    return;
  }
  xSemaphoreGive(motion_detection_active);

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

  ESP_LOGI(TAG,
           "Tasks created successfully. Main loop "
           "running on Core %d",
           xPortGetCoreID());

  // ESP_LOGI(TAG, "Artificially starting motion detection task.");
  // start_motion_detection_task(&motionDetectionTaskHandle, capture_mutex);
}