#include "wifi_connect.h"

#include <string.h>

#include "esp_event.h"
#include "esp_log.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "lwip/err.h"
#include "lwip/sys.h"
#include "nvs_flash.h"

// Wi-Fi credentials (Replace with your actual Wi-Fi credentials)
#define WIFI_SSID CONFIG_WIFI_SSID
#define WIFI_PASS CONFIG_WIFI_PASSWORD

// Maximum number of retries for Wi-Fi connection
#define MAXIMUM_RETRY 5

// Event group to handle Wi-Fi connection events
static EventGroupHandle_t s_wifi_event_group;

// Event bits for connection success and failure
#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT BIT1

static const char *TAG = "WiFi_Station";
static int s_retry_num = 0;

SemaphoreHandle_t wifi_connection_semaphore;

// Event handler to handle Wi-Fi and IP events
static void event_handler(void *arg, esp_event_base_t event_base,
                          int32_t event_id, void *event_data) {
  if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
    ESP_LOGI(TAG, "Wi-Fi started, attempting to connect...");
    esp_wifi_connect();
  } else if (event_base == WIFI_EVENT &&
             event_id == WIFI_EVENT_STA_DISCONNECTED) {
    if (s_retry_num < MAXIMUM_RETRY) {
      ESP_LOGW(TAG, "Wi-Fi disconnected, retrying to connect (attempt %d)...",
               s_retry_num + 1);
      esp_wifi_connect();
      s_retry_num++;
    } else {
      ESP_LOGE(TAG,
               "Maximum retry limit reached. Failed to connect to the Wi-Fi "
               "network.");
      xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
    }
  } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
    ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
    ESP_LOGI(TAG, "Got IP address: " IPSTR, IP2STR(&event->ip_info.ip));
    s_retry_num = 0;  // Reset retry count upon successful connection
    xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
  }
}

// void app_main() {
//   ESP_LOGI(TAG, "Trying to initialize WiFi");
//   initialize_wifi();
// }

// Function to initialize NVS and Wi-Fi in Station mode
void initialize_wifi(void) {
  ESP_LOGI(TAG, "Initializing NVS for Wi-Fi connection...");
  wifi_connection_semaphore = xSemaphoreCreateBinary();

  // Initialize NVS flash storage (required for Wi-Fi functionality)
  esp_err_t ret = nvs_flash_init();
  if (ret == ESP_ERR_NVS_NO_FREE_PAGES ||
      ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    ESP_LOGW(TAG, "NVS flash init error, erasing and reinitializing...");
    ESP_ERROR_CHECK(nvs_flash_erase());
    ret = nvs_flash_init();
  }
  ESP_ERROR_CHECK(ret);

  ESP_LOGI(TAG, "Starting Wi-Fi in Station mode...");

  s_wifi_event_group = xEventGroupCreate();
  ESP_ERROR_CHECK(esp_netif_init());
  ESP_ERROR_CHECK(esp_event_loop_create_default());
  esp_netif_create_default_wifi_sta();

  wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
  ESP_ERROR_CHECK(esp_wifi_init(&cfg));

  ESP_LOGI(TAG, "Registering Wi-Fi event handlers...");
  esp_event_handler_instance_t instance_any_id;
  esp_event_handler_instance_t instance_got_ip;
  ESP_ERROR_CHECK(esp_event_handler_instance_register(
      WIFI_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL, &instance_any_id));
  ESP_ERROR_CHECK(esp_event_handler_instance_register(
      IP_EVENT, IP_EVENT_STA_GOT_IP, &event_handler, NULL, &instance_got_ip));

  wifi_config_t wifi_config = {
      .sta =
          {
              .ssid = WIFI_SSID,
              .password = WIFI_PASS,
              .threshold.authmode = WIFI_AUTH_WPA2_PSK,
          },
  };

  ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
  ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
  ESP_ERROR_CHECK(esp_wifi_start());

  ESP_LOGI(TAG, "Wi-Fi initialization finished.");

  // Wait for Wi-Fi connection
  EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
                                         WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
                                         pdFALSE, pdFALSE, portMAX_DELAY);

  if (bits & WIFI_CONNECTED_BIT) {
    ESP_LOGI(TAG, "Successfully connected to the Wi-Fi network: SSID:%s",
             WIFI_SSID);
    xSemaphoreGive(
        wifi_connection_semaphore);  // Signal that Wi-Fi is connected
  } else if (bits & WIFI_FAIL_BIT) {
    ESP_LOGE(TAG, "Failed to connect to the Wi-Fi network: SSID:%s", WIFI_SSID);
  } else {
    ESP_LOGE(TAG, "Unexpected event occurred during Wi-Fi connection!");
  }
}
