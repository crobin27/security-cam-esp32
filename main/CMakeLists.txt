idf_component_register(SRCS "main.c" "wifi_connect.c" "camera_task.c" "aws_upload.c" "motion_detection.c" "aws_upload.c"
                       INCLUDE_DIRS ".")

                       # Add this line to point to your Kconfig file
# Specify the inclusion of your custom Kconfig options
set(COMPONENT_REQUIRES espressif__esp32-camera)
