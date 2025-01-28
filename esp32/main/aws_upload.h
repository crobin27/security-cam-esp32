#ifndef AWS_UPLOAD_H
#define AWS_UPLOAD_H
#include <stddef.h>
#include <stdint.h>
void start_upload_task(void);
void upload_image_to_s3(const uint8_t *image_data, size_t image_size,
                        const char *folder_name, const char *file_type);
#endif
