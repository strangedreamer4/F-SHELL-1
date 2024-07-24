#!/bin/bash

# Find the path to f-shell.py
SCRIPT_PATH=$(find / -name "f-shell.py" 2>/dev/null | head -n 1)

if [ -z "$SCRIPT_PATH" ]; then
    echo "f-shell.py not found. Please make sure the script is in the filesystem."
    exit 1
fi

# Get the directory containing the script
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

# Define the service file content with the found path
SERVICE_FILE_CONTENT="[Unit]
Description=Run f-shell.py in the background
After=network.target

[Service]
ExecStart=/usr/bin/python3 $SCRIPT_PATH
WorkingDirectory=$SCRIPT_DIR
Restart=always
User=$(whoami)
Group=$(id -gn)
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=f-shell
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target"

# Define the path to the service file
SERVICE_FILE_PATH="/etc/systemd/system/f-shell.service"

# Create the service file
echo "$SERVICE_FILE_CONTENT" | sudo tee $SERVICE_FILE_PATH > /dev/null

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable f-shell.service

# Start the service immediately
sudo systemctl start f-shell.service

echo "f-shell service has been created and started successfully."
