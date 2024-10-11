#ifndef MOTION_DETECTION_H
#define MOTION_DETECTION_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

bool analyze_frame_for_motion(const uint8_t *current_frame, size_t frame_len);

#endif // MOTION_DETECTION_H
