#ifndef CAMERA_H
#define CAMERA_H

#include <stddef.h>
#include "esp_err.h"
#include "esp_camera.h"

// Function to initialize the camera
esp_err_t init_camera(void);

// Function to capture an image and return the frame buffer
camera_fb_t *capture_image(void);

// Function to return a captured image back to the driver
void release_image(camera_fb_t *pic);

esp_err_t reinitialize_camera(pixformat_t pixel_format,
                              framesize_t frame_size);

#endif  // CAMERA_H