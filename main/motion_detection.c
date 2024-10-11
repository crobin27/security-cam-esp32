#include "motion_detection.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "esp_log.h"

static const char *TAG = "Motion_Detection";

// Store the previous frame for comparison
static uint8_t *previous_frame = NULL;

bool analyze_frame_for_motion(const uint8_t *current_frame, size_t frame_len) {
    if (previous_frame == NULL) {
        // Allocate memory for the previous frame and initialize it
        previous_frame = (uint8_t *)malloc(frame_len);
        if (previous_frame == NULL) {
            ESP_LOGE(TAG, "Failed to allocate memory for previous frame");
            return false;
        }
        memcpy(previous_frame, current_frame, frame_len);
        return false; // No motion detected on the first frame
    }

    // Calculate the difference between the current frame and the previous frame
    int diff_count = 0;
    int threshold = 30; // Adjust this value to change motion sensitivity
    for (size_t i = 0; i < frame_len; i++) {
        int pixel_diff = abs(current_frame[i] - previous_frame[i]);
        if (pixel_diff > threshold) {
            diff_count++;
        }
    }

    // Update the previous frame with the current frame
    memcpy(previous_frame, current_frame, frame_len);

    // Determine if motion is detected
    int motion_threshold = frame_len * 0.05; // 5% of pixels change indicates motion
    bool motion_detected = (diff_count > motion_threshold);
    return motion_detected;
}
