#include <stdio.h>

#include "aws_upload.h"  // Include the AWS upload header
#include "camera.h"      // Include the camera task header
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "wifi_connect.h"      // Include the Wi-Fi connection header
#include "aws_iot.h"

static const char *TAG = "App_Main";

// Certificates
extern const uint8_t client_cert_pem_start[] asm("_binary_client_cert_pem_start");
extern const uint8_t private_key_pem_start[] asm("_binary_private_key_pem_start");
extern const uint8_t root_ca_pem_start[] asm("_binary_root_ca_pem_start");

// MQTT Broker URI
#define MQTT_BROKER_URI CONFIG_AWS_IOT_ENDPOINT  // Define this in sdkconfig

void app_main() {
    ESP_LOGI(TAG, "ESP32 Starting Up");

    initialize_wifi();

    if (init_camera() != ESP_OK) {
        ESP_LOGE(TAG, "Camera initialization failed. Stopping.");
        return;
    }

    initialize_mqtt(MQTT_BROKER_URI);

    ESP_LOGI(TAG, "ESP32 initialized and ready.");
    while (true) {
        vTaskDelay(1000 / portTICK_PERIOD_MS);  // Keep main task running
    }
}