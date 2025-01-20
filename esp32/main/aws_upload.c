#include "aws_upload.h"
#include "esp_http_client.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

// External declaration of the semaphore defined in wifi_connect.c
extern SemaphoreHandle_t wifi_connection_semaphore;

// Tag for logging
static const char *TAG = "AWS_UPLOAD";

extern const uint8_t root_ca_pem_start[] asm("_binary_root_ca_pem_start");
extern const uint8_t root_ca_pem_end[] asm("_binary_root_ca_pem_end");

// Function to upload an image to the S3 bucket
void upload_image_to_s3(const uint8_t *image_data, size_t image_size) {

  // Check if Wi-Fi connection is established using the semaphore
  if (wifi_connection_semaphore != NULL &&
      xSemaphoreTake(wifi_connection_semaphore, portMAX_DELAY)) {
    ESP_LOGI(TAG, "Wi-Fi connected. Proceeding with image upload.");

    // Define the endpoint URL using the config value
    char url[256];
    snprintf(url, sizeof(url), "%s", CONFIG_AWS_API_URL);

    // Configure the HTTP client for the image upload
    esp_http_client_config_t config = {.url = url,
                                       .method = HTTP_METHOD_POST,
                                       .cert_pem =
                                           (const char *)root_ca_pem_start,
                                       .timeout_ms = 5000,
                                       .transport_type = HTTP_TRANSPORT_OVER_SSL

    };

    esp_http_client_handle_t client = esp_http_client_init(&config);
    if (client == NULL) {
      ESP_LOGE(TAG, "Failed to initialize HTTP client");
      xSemaphoreGive(wifi_connection_semaphore);
      return;
    }

    // Set the request headers for binary data (JPEG image)
    esp_http_client_set_header(client, "Content-Type", "image/jpeg");

    // Send the POST request with the image data
    esp_err_t err = esp_http_client_open(client, image_size);
    if (err == ESP_OK) {
      int write_len =
          esp_http_client_write(client, (const char *)image_data, image_size);
      if (write_len != image_size) {
        ESP_LOGE(TAG,
                 "Error: Data size mismatch. Sent %d bytes, expected %d bytes.",
                 write_len, image_size);
      }

      int fetch_err = esp_http_client_fetch_headers(client);
      if (fetch_err >= 0) {
        int status_code = esp_http_client_get_status_code(client);
        ESP_LOGI(TAG, "status_code=%d", status_code);
      } else {
        ESP_LOGE(TAG, "Failed to fetch headers: %d", fetch_err);
      }

      esp_http_client_close(client);
      int status_code = esp_http_client_get_status_code(client);
      if (status_code >= 200 && status_code < 300) {
        ESP_LOGI(TAG, "Server responded with status: %d. Success!",
                 status_code);
      } else {
        ESP_LOGE(TAG, "Server responded with status: %d. Something went wrong.",
                 status_code);
      }
      esp_http_client_cleanup(client);
    }
    xSemaphoreGive(wifi_connection_semaphore);
  } else {
    ESP_LOGE(TAG, "Wi-Fi not connected. Image upload failed.");
  }
}