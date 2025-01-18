idf_component_register(
    SRCS "aws_iot.c" "camera.c" "main.c" "wifi_connect.c" "aws_upload.c"
    INCLUDE_DIRS "."
    EMBED_FILES "certs/client_cert.pem" "certs/private_key.pem" "certs/root_ca.pem"
)

                       
# Specify the inclusion of your custom Kconfig options
set(COMPONENT_REQUIRES espressif__esp32-camera)
