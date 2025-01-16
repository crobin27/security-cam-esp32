#include "camera.h"

#include <esp_log.h>
#include <esp_system.h>
#include <nvs_flash.h>
#include <string.h>
#include <sys/param.h>

#include "aws_upload.h"
#include "esp_camera.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "freertos/task.h"
#include "wifi_connect.h"  // For the Wi-Fi semaphore

#define BOARD_ESP32CAM_AITHINKER 1

// ESP32Cam (AiThinker) PIN Map
#ifdef BOARD_ESP32CAM_AITHINKER

#define CAM_PIN_PWDN 32
#define CAM_PIN_RESET -1  // software reset will be performed
#define CAM_PIN_XCLK 0
#define CAM_PIN_SIOD 26
#define CAM_PIN_SIOC 27

#define CAM_PIN_D7 35
#define CAM_PIN_D6 34
#define CAM_PIN_D5 39
#define CAM_PIN_D4 36
#define CAM_PIN_D3 21
#define CAM_PIN_D2 19
#define CAM_PIN_D1 18
#define CAM_PIN_D0 5
#define CAM_PIN_VSYNC 25
#define CAM_PIN_HREF 23
#define CAM_PIN_PCLK 22

#endif

static const char *TAG = "Camera";

// External declaration of the semaphore defined in wifi_connect.c
extern SemaphoreHandle_t wifi_connection_semaphore;

#if ESP_CAMERA_SUPPORTED
static camera_config_t camera_config = {
    .pin_pwdn = CAM_PIN_PWDN,
    .pin_reset = CAM_PIN_RESET,
    .pin_xclk = CAM_PIN_XCLK,
    .pin_sccb_sda = CAM_PIN_SIOD,
    .pin_sccb_scl = CAM_PIN_SIOC,
    .pin_d7 = CAM_PIN_D7,
    .pin_d6 = CAM_PIN_D6,
    .pin_d5 = CAM_PIN_D5,
    .pin_d4 = CAM_PIN_D4,
    .pin_d3 = CAM_PIN_D3,
    .pin_d2 = CAM_PIN_D2,
    .pin_d1 = CAM_PIN_D1,
    .pin_d0 = CAM_PIN_D0,
    .pin_vsync = CAM_PIN_VSYNC,
    .pin_href = CAM_PIN_HREF,
    .pin_pclk = CAM_PIN_PCLK,
    .xclk_freq_hz = 20000000,
    .ledc_timer = LEDC_TIMER_0,
    .ledc_channel = LEDC_CHANNEL_0,
    .pixel_format = PIXFORMAT_JPEG,  // JPEG for smaller file sizes
    .frame_size = FRAMESIZE_HD,  // Moderate frame size to reduce memory usage
    .jpeg_quality = 10,          // Higher value means lower quality
    .fb_count = 1,               // Only one frame buffer to reduce memory usage
    .fb_location = CAMERA_FB_IN_PSRAM,
    .grab_mode = CAMERA_GRAB_WHEN_EMPTY,
};

// Function to initialize the camera
esp_err_t init_camera(void) {
  esp_err_t err = esp_camera_init(&camera_config);
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "Camera Init Failed: %s", esp_err_to_name(err));
    return err;
  }
  ESP_LOGI(TAG, "Camera successfully initialized");
  return ESP_OK;
}

// Function to capture an image and return the frame buffer
camera_fb_t *capture_image(void) {
  camera_fb_t *pic = esp_camera_fb_get();
  if (!pic) {
    ESP_LOGE(TAG, "Failed to capture image.");
    return NULL;
  }
  ESP_LOGI(TAG, "Image captured. Size: %zu bytes", pic->len);
  return pic;
}

// Function to return a captured image back to the driver
void release_image(camera_fb_t *pic) {
  if (pic) {
    esp_camera_fb_return(pic);
    ESP_LOGI(TAG, "Returned image buffer to driver.");
  } else {
    ESP_LOGW(TAG, "Attempted to return a NULL image buffer.");
  }
}

// Function to generate a unique filename based on the current time
void generate_image_filename(char *buffer, size_t buffer_size) {
  time_t now;
  struct tm timeinfo;
  time(&now);
  localtime_r(&now, &timeinfo);
  strftime(buffer, buffer_size, "image_%Y%m%d_%H%M%S.jpg", &timeinfo);
}

#else
void start_camera_task(void) {
  ESP_LOGE(TAG, "Camera support is not available for this chip.");
}
#endif