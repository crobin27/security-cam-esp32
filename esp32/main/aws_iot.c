#include "aws_iot.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "esp_log.h"
#include "mqtt_client.h"
#include "camera.h"
#include "aws_upload.h"

// Logging tag
static const char *TAG = "AWS_IoT";

// MQTT client handle
static esp_mqtt_client_handle_t mqtt_client;

// Certificate declarations
extern const uint8_t client_cert_pem_start[] asm("_binary_client_cert_pem_start");
extern const uint8_t client_cert_pem_end[] asm("_binary_client_cert_pem_end");

extern const uint8_t private_key_pem_start[] asm("_binary_private_key_pem_start");
extern const uint8_t private_key_pem_end[] asm("_binary_private_key_pem_end");

extern const uint8_t root_ca_pem_start[] asm("_binary_root_ca_pem_start");
extern const uint8_t root_ca_pem_end[] asm("_binary_root_ca_pem_end");


// MQTT event handler
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data) {
    esp_mqtt_event_handle_t event = event_data;

    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "Connected to AWS IoT Core");

            // Subscribe to the topic
            esp_mqtt_client_subscribe(mqtt_client, "esp32/take_picture", 1);
            break;

        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "Disconnected from AWS IoT Core");
            break;

        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "Received data on topic: %.*s", event->topic_len, event->topic);
            ESP_LOGI(TAG, "Message: %.*s", event->data_len, event->data);

            // Handle the "take picture" command
            if (strncmp(event->topic, "esp32/take_picture", event->topic_len) == 0) {
                ESP_LOGI(TAG, "Take picture command received");

                // Capture an image
                camera_fb_t *fb = capture_image();
                if (fb == NULL) {
                    ESP_LOGE(TAG, "Camera capture failed.");
                } else {
                    ESP_LOGI(TAG, "Image captured. Uploading...");
                    upload_image_to_s3(fb->buf, fb->len);
                    ESP_LOGI(TAG, "Image uploaded successfully.");
                    release_image(fb);
                }
            }
            break;

        case MQTT_EVENT_ERROR:
            ESP_LOGE(TAG, "MQTT_EVENT_ERROR");
            break;

        default:
            ESP_LOGI(TAG, "Unhandled event ID: %d", event->event_id);
            break;
    }
}

// Initialize MQTT
void initialize_mqtt(const char *mqtt_endpoint) {
    const esp_mqtt_client_config_t mqtt_cfg = {
    .broker = {
        .address.uri = mqtt_endpoint,
        .verification.certificate = (const char *)root_ca_pem_start,
    },
    .credentials = {
        .authentication = {
            .certificate = (const char *)client_cert_pem_start,
            .key = (const char *)private_key_pem_start,
        },
    },
    };

    mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    if (mqtt_client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return;
    }

    esp_mqtt_client_register_event(mqtt_client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(mqtt_client);

    ESP_LOGI(TAG, "MQTT client started");
}
