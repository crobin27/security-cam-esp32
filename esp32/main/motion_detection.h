#ifndef MOTION_DETECTION_H
#define MOTION_DETECTION_H

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"

void motion_detection_task(void *param);
void start_motion_detection_task(TaskHandle_t *taskHandle, SemaphoreHandle_t capture_mutex);

#endif
