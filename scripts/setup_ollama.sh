#!/bin/bash

# Check if the script is run with a username argument
if [ -z "$1" ]; then
    echo "Usage: sudo $0 <USERNAME>"
    exit 1
fi

CURRENT_USER="$1"
SERVICE_FILE="/etc/systemd/system/ollama.service"
ENVIRONMENT_LINE="Environment=OLLAMA_MODELS=/home/${CURRENT_USER}/Projects/LLM/ollama_models"

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Replace User and Group with the provided username
sed -i "s/^User=.*/User=${CURRENT_USER}/" "$SERVICE_FILE"
sed -i "s/^Group=.*/Group=${CURRENT_USER}/" "$SERVICE_FILE"

# Ensure the Environment variable exists under [Service]
if grep -q "^\[Service\]" "$SERVICE_FILE"; then
    if ! grep -q "$ENVIRONMENT_LINE" "$SERVICE_FILE"; then
        sed -i "/^\[Service\]/a $ENVIRONMENT_LINE" "$SERVICE_FILE"
    fi
else
    echo -e "\n[Service]\n$ENVIRONMENT_LINE" >> "$SERVICE_FILE"
fi

echo "Service file updated. Remember to reload and restart the service:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart ollama.service"
