#include "aws_upload.h"

#include <stdio.h>
#include <string.h>

#include "esp_http_client.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"

// External declaration of the semaphore defined in wifi_connect.c
extern SemaphoreHandle_t wifi_connection_semaphore;

// Tag for logging
static const char *TAG = "AWS_UPLOAD";

static const char *aws_root_ca_pem =
    "-----BEGIN CERTIFICATE-----\n"
    "MIIDQTCCAimgAwIBAgITBmyfz5m/jAo54vB4ikPmljZbyjANBgkqhkiG9w0BAQsF\n"
    "ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6\n"
    "b24gUm9vdCBDQSAxMB4XDTE1MDUyNjAwMDAwMFoXDTM4MDExNzAwMDAwMFowOTEL\n"
    "MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv\n"
    "b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj\n"
    "ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM\n"
    "9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw\n"
    "IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6\n"
    "VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L\n"
    "93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm\n"
    "jgSubJrIqg0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC\n"
    "AYYwHQYDVR0OBBYEFIQYzIU07LwMlJQuCFmcx7IQTgoIMA0GCSqGSIb3DQEBCwUA\n"
    "A4IBAQCY8jdaQZChGsV2USggNiMOruYou6r4lK5IpDB/G/wkjUu0yKGX9rbxenDI\n"
    "U5PMCCjjmCXPI6T53iHTfIUJrU6adTrCC2qJeHZERxhlbI1Bjjt/msv0tadQ1wUs\n"
    "N+gDS63pYaACbvXy8MWy7Vu33PqUXHeeE6V/Uq2V8viTO96LXFvKWlJbYK8U90vv\n"
    "o/ufQJVtMVT8QtPHRh8jrdkPSHCa2XV4cdFyQzR1bldZwgJcJmApzyMZFo6IQ6XU\n"
    "5MsI+yMRQ+hDKXJioaldXgjUkK642M4UwtBV8ob2xJNDd2ZhwLnoQdeXeGADbkpy\n"
    "rqXRfboQnoZsG4q5WTP468SQvvG5\n"
    "-----END CERTIFICATE-----\n";

// Function to upload a test file to the S3 bucket

// Function to upload an image to the S3 bucket
void upload_image_to_s3(const uint8_t *image_data, size_t image_size,
                        const char *filename) {
  ESP_LOGI(TAG, "Waiting for Wi-Fi connection...");

  // Check if Wi-Fi connection is established using the semaphore
  if (wifi_connection_semaphore != NULL &&
      xSemaphoreTake(wifi_connection_semaphore, portMAX_DELAY)) {
    ESP_LOGI(TAG, "Wi-Fi connected. Proceeding with image upload.");

    // Define the endpoint URL using the config value
    char url[256];
    snprintf(url, sizeof(url), "%s/%s", CONFIG_AWS_API_URL, filename);

    // Configure the HTTP client for the image upload
    esp_http_client_config_t config = {
        .url = url,
        .method = HTTP_METHOD_PUT,
        .cert_pem = aws_root_ca_pem,  // Use the root CA certificate for SSL/TLS
        .timeout_ms = 5000,
    };

    esp_http_client_handle_t client = esp_http_client_init(&config);
    if (client == NULL) {
      ESP_LOGE(TAG, "Failed to initialize HTTP client");
      return;
    }

    // Set the request headers for binary data (JPEG image)
    esp_http_client_set_header(client, "Content-Type", "image/jpeg");

    // Send the PUT request with the image data
    esp_err_t err = esp_http_client_open(client, image_size);
    if (err == ESP_OK) {
      int write_len =
          esp_http_client_write(client, (const char *)image_data, image_size);
      if (write_len != image_size) {
        ESP_LOGE(TAG,
                 "Error: Data size mismatch. Sent %d bytes, expected %d bytes.",
                 write_len, image_size);
      }

      if (write_len < 0) {
        ESP_LOGE(TAG, "Error in sending image data to the server");
      } else {
        ESP_LOGI(TAG, "Image uploaded successfully");
      }
    } else {
      ESP_LOGE(TAG, "Failed to open HTTP connection: %s", esp_err_to_name(err));
    }

    // Close the HTTP connection and clean up
    esp_http_client_close(client);
    esp_http_client_cleanup(client);
  } else {
    ESP_LOGE(TAG, "Wi-Fi not connected. Image upload failed.");
  }
}

// Example usage of the image upload function
void start_upload_task(void) {
  // ESP_LOGI(TAG, "Starting the upload task...");

  // This function can be called with image data once the image is captured
  // Example: upload_image_to_s3(image_data, image_size, "captured-image.jpg");
}
