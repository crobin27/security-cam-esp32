#include <inttypes.h>  // Include for the PRIu32 macro

#include "aws_upload.h"
#include "camera.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define MOTION_THRESHOLD 100000  // Threshold for motion detection
#define NUM_PHOTOS_ON_MOTION \
  3                           // Number of photos to capture on motion detection
#define CAPTURE_INTERVAL 500  // Time (ms) between photo captures after motion

static const char *TAG = "Motion_Detection";  // Define TAG for logging

// Function to detect motion by comparing two images
bool detect_motion(camera_fb_t *img1, camera_fb_t *img2) {
  if (img1->len != img2->len) return false;  // Ensure sizes match

  uint32_t diff_sum = 0;
  for (size_t i = 0; i < img1->len; i++) {
    int diff = img1->buf[i] - img2->buf[i];
    diff_sum += (diff > 0) ? diff : -diff;  // Absolute value of difference
  }

  ESP_LOGI(TAG, "Total difference: %" PRIu32, diff_sum);

  // If the difference exceeds the threshold, motion is detected
  return diff_sum > MOTION_THRESHOLD;
}

// Function to capture and upload multiple photos when motion is detected
void capture_and_upload_photos() {
  for (int i = 0; i < NUM_PHOTOS_ON_MOTION; i++) {
    ESP_LOGI(TAG, "Capturing image %d out of %d after motion detection", i + 1,
             NUM_PHOTOS_ON_MOTION);

    // Capture an image
    camera_fb_t *image = capture_image();
    if (image == NULL) {
      ESP_LOGE(TAG, "Failed to capture image %d", i + 1);
      return;
    }

    // Generate filename and upload the image to S3
    char image_filename[64];
    generate_image_filename(image_filename, sizeof(image_filename));
    upload_image_to_s3(image->buf, image->len, image_filename);

    // Release the image back to the camera driver
    release_image(image);

    // Delay before taking the next photo
    vTaskDelay(CAPTURE_INTERVAL / portTICK_PERIOD_MS);
  }
}

// Motion detection task
static void motion_detection_task(void *pvParameters) {
  camera_fb_t *prev_image = NULL;

  while (1) {
    // Capture a new image
    camera_fb_t *new_image = capture_image();
    if (new_image == NULL) {
      ESP_LOGE(TAG, "Failed to capture image for motion detection");
      vTaskDelay(1000 / portTICK_PERIOD_MS);
      continue;
    }

    // Compare with the previous image, if available
    if (prev_image != NULL) {
      if (detect_motion(prev_image, new_image)) {
        ESP_LOGI(TAG, "Motion detected! Capturing and uploading images...");
        capture_and_upload_photos();  // Upload photos when motion is detected
      }
    }

    // Set the new image as the previous one for the next comparison
    prev_image = new_image;
    // Release the previous image back to the camera driver
    release_image(prev_image);

    // Delay before the next capture to avoid constant capturing
    vTaskDelay(
        2000 /
        portTICK_PERIOD_MS);  // Adjust delay for motion detection sensitivity
  }
}

// Function to start the motion detection task
void start_motion_detection_task() {
  ESP_LOGI(TAG, "Starting motion detection task...");
  xTaskCreate(motion_detection_task, "motion_detection_task", 8192, NULL, 5,
              NULL);
}
