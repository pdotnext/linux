# Create files to manage services

#!/bin/bash
# Description: Generate scripts to start, stop and restart httpd service
#
# Using strict error handling:
# -e: Exit immediately if a command exits with non-zero status
# -u: Treat unset variables as an error
# -o: pipefail: Set the exit code of a pipeline \
# to the rightmost command that failed
set -euo pipefail

# --- Configuration Variables ---
SERVICE_NAME="httpd"
TARGET_DIR="/usr/local/bin"
# This script will need 'sudo' privileges to write to
# $TARGET_DIR
# Indentation after do is not adhered because
# of the bug in bash

for SERVICE_ACTION in {start,stop,restart};
do
    printf %s"
#!/bin/bash
/usr/bin/systemctl $SERVICE_ACTION $SERVICE_NAME
" | sudo tee $TARGET_DIR/${SERVICE_ACTION}"_"${SERVICE_NAME}.sh
sudo chown -v root: $TARGET_DIR/${SERVICE_ACTION}"_"${SERVICE_NAME}.sh
sudo chmod -v 0700 $TARGET_DIR/${SERVICE_ACTION}"_"${SERVICE_NAME}.sh
done