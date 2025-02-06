#include "motion_detection.h"
#include "aws_upload.h"
#include "camera.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "freertos/task.h"
#include <stdlib.h>
#include <string.h>

#define MAX_FRAMES 10 // Maximum number of frames in the FIFO queue
#define MOTION_TIMEOUT 120000
#define FRAME_DIFF_THRESHOLD 450000 // Threshold for motion detection, arbitrary

static const char *TAG = "MotionDetection";

// FIFO queue for storing frames
static uint8_t *frame_buffer[MAX_FRAMES];
static size_t frame_sizes[MAX_FRAMES];
static int current_frame_index = 0;

extern SemaphoreHandle_t capture_mutex;
extern SemaphoreHandle_t motion_detection_active;

static void store_frame(uint8_t *data, size_t size);
static int compare_frames(uint8_t *frame1, size_t size1, uint8_t *frame2,
                          size_t size2);
void motion_detection_task(void *param) {
  ESP_LOGI(TAG, "Motion detection task started.");

  if (reinitialize_camera(PIXFORMAT_GRAYSCALE, FRAMESIZE_QVGA) == ESP_OK) {
    ESP_LOGI(TAG, "Camera set to grayscale colored mode for motion detection.");
  } else {
    ESP_LOGE(TAG, "Failed to set camera to grayscale mode.");
  }

  // Capture reference frames for initialization
  ESP_LOGI(TAG, "Initializing reference frames...");
  for (int i = 0; i < MAX_FRAMES + 5; i++) {
    xSemaphoreTake(capture_mutex, portMAX_DELAY);
    camera_fb_t *fb = capture_image();
    if (!fb) {
      ESP_LOGE(TAG, "Failed to capture reference frame %d.", i);
      xSemaphoreGive(capture_mutex);
      vTaskDelay(pdMS_TO_TICKS(500));
      continue;
    }
    store_frame(fb->buf, fb->len);
    release_image(fb);
    xSemaphoreGive(capture_mutex);
    vTaskDelay(pdMS_TO_TICKS(750));
  }
  ESP_LOGI(TAG, "Reference frames initialized. Starting motion detection.");

  int start_time = xTaskGetTickCount();

  while (pdTICKS_TO_MS(xTaskGetTickCount() - start_time) < MOTION_TIMEOUT) {
    // Capture a new frame
    xSemaphoreTake(capture_mutex, portMAX_DELAY);
    camera_fb_t *fb = capture_image();
    if (!fb) {
      ESP_LOGE(TAG, "Failed to capture new frame.");
      xSemaphoreGive(capture_mutex);
      vTaskDelay(pdMS_TO_TICKS(2000));
      continue;
    }

    // Compare the new frame with the most recent frame in the FIFO queue
    int diff =
        compare_frames(frame_buffer[current_frame_index],
                       frame_sizes[current_frame_index], fb->buf, fb->len);

    // Store the new frame in the FIFO queue
    store_frame(fb->buf, fb->len);
    release_image(fb);
    xSemaphoreGive(capture_mutex);

    // Check if motion is detected
    if (diff > FRAME_DIFF_THRESHOLD) {
      ESP_LOGI(TAG, "Motion detected! Difference: %d", diff);

      // Capture three relevant frames: before, during, and after motion
      int before_index = (current_frame_index + MAX_FRAMES - 2) % MAX_FRAMES;
      int during_index = (current_frame_index + MAX_FRAMES - 1) % MAX_FRAMES;

      ESP_LOGI(TAG, "Captured motion frames: before and during.");

      // Delay to capture the "after" frame
      vTaskDelay(pdMS_TO_TICKS(1000));
      xSemaphoreTake(capture_mutex, portMAX_DELAY);
      camera_fb_t *fb_after = capture_image();
      if (!fb_after) {
        ESP_LOGE(TAG, "Failed to capture 'after' frame.");
        xSemaphoreGive(capture_mutex);
      } else {
        // Store the "after" frame in the FIFO queue
        store_frame(fb_after->buf, fb_after->len);
        release_image(fb_after);
        ESP_LOGI(TAG, "Captured 'after' motion frame.");
        xSemaphoreGive(capture_mutex);
      }

      int after_index = current_frame_index;

      ESP_LOGI(TAG, "Captured motion frames: before, during, and after.");

      // Placeholder for uploading frames to AWS
      ESP_LOGI(TAG, "Placeholder for uploading frames: before, during, after.");
      upload_image_to_s3(frame_buffer[before_index], frame_sizes[before_index],
                         "motion-detection-images", "image/bmp");
      upload_image_to_s3(frame_buffer[during_index], frame_sizes[during_index],
                         "motion-detection-images", "image/bmp");
      upload_image_to_s3(frame_buffer[after_index], frame_sizes[after_index],
                         "motion-detection-images", "image/bmp");

      // Reinitialize reference frames after motion detection
      ESP_LOGI(TAG, "Reinitializing reference frames after motion detection.");
      for (int i = 0; i < MAX_FRAMES + 5; i++) {
        xSemaphoreTake(capture_mutex, portMAX_DELAY);
        camera_fb_t *fb_ref = capture_image();
        if (!fb_ref) {
          ESP_LOGE(TAG, "Failed to capture reference frame %d.", i);
          xSemaphoreGive(capture_mutex);
          vTaskDelay(pdMS_TO_TICKS(700));
          continue;
        }
        store_frame(fb_ref->buf, fb_ref->len);
        release_image(fb_ref);
        xSemaphoreGive(capture_mutex);
        vTaskDelay(pdMS_TO_TICKS(500));
      }
      ESP_LOGI(TAG, "Reference frames reinitialized.");

      // Delay for 5 seconds before restarting motion detection
      vTaskDelay(pdMS_TO_TICKS(5000));
    } else {
      ESP_LOGI(TAG, "No motion detected. Difference: %d", diff);
    }

    vTaskDelay(pdMS_TO_TICKS(1000)); // Delay between captures
  }

  ESP_LOGI(TAG, "Motion detection task completed.");
  vTaskDelete(NULL);
  xSemaphoreGive(motion_detection_active);
}

static void store_frame(uint8_t *data, size_t size) {
  // Free memory for the current frame index if already allocated
  if (frame_buffer[current_frame_index]) {
    free(frame_buffer[current_frame_index]);
  }

  // Allocate memory for the new frame
  frame_buffer[current_frame_index] = (uint8_t *)malloc(size);
  if (frame_buffer[current_frame_index]) {
    memcpy(frame_buffer[current_frame_index], data, size);
    frame_sizes[current_frame_index] = size;
    current_frame_index = (current_frame_index + 1) % MAX_FRAMES;
  } else {
    ESP_LOGE(TAG, "Failed to allocate memory for frame.");
  }
}
static int compare_frames(uint8_t *frame1, size_t size1, uint8_t *frame2,
                          size_t size2) {
  if (!frame1 || !frame2) {
    ESP_LOGW(TAG, "One or both frames are null.");
    return INT_MAX;
  }

  if (size1 != size2) {
    ESP_LOGW(TAG, "Frame size mismatch: size1=%zu, size2=%zu", size1, size2);
    return INT_MAX;
  }

  int diff = 0;
  for (size_t i = 0; i < size1; i++) {
    diff += abs(frame1[i] - frame2[i]); // Accumulate absolute pixel differences
  }

  return diff;
}

void start_motion_detection_task(TaskHandle_t *taskHandle,
                                 SemaphoreHandle_t capture_mutex) {
  if (*taskHandle != NULL) {
    ESP_LOGW(TAG, "Motion detection task is already running.");
    return;
  }

  BaseType_t result =
      xTaskCreatePinnedToCore(motion_detection_task, "MotionDetectionTask",
                              4096, (void *)capture_mutex, 1, taskHandle, 1);

  if (result == pdPASS) {
    ESP_LOGI(TAG, "Motion detection task started successfully.");
  } else {
    ESP_LOGE(TAG, "Failed to start motion detection task.");
  }
}