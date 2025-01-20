#ifndef AWS_IOT_H
#define AWS_IOT_H

#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"

void initialize_mqtt(const char *mqtt_endpoint, QueueHandle_t commandQueue);
#endif  // AWS_IOT_H