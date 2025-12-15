# Create files to manage services

#!/bin/fish
# Description: Generate scripts to start, stop and restart httpd service
#

# --- Configuration Variables ---
set SERVICE_NAME "httpd"
set TARGET_DIR "/usr/local/bin"
# This script will need 'sudo' privileges to write to
# $TARGET_DIR

for SERVICE_ACTION in {start,stop,restart};
    printf %s\n "
    #!/bin/bash
    /usr/bin/systemctl $SERVICE_ACTION $SERVICE_NAME
    " | sudo tee $TARGET_DIR/$SERVICE_ACTION"_"$SERVICE_NAME.sh
    sudo chown -v root: $TARGET_DIR/$SERVICE_ACTION"_"$SERVICE_NAME.sh
    sudo chmod -v 0700 $TARGET_DIR/$SERVICE_ACTION"_"$SERVICE_NAME.sh
end