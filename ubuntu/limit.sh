#!/bin/bash

# Repository URL
REPO="https://raw.githubusercontent.com/SaputraTech/M4k4r0n1/main/"

# Download systemd service files
for service in limitvmess limitvless limittrojan limitshadowsocks; do
    wget -q -O "/etc/systemd/system/${service}.service" "${REPO}ubuntu/${service}.service" && 
    chmod +x "/etc/systemd/system/${service}.service"
    
    # Enable and start the service
    systemctl daemon-reload
    systemctl enable --now "$service"
done

# Download Xray limit configuration files
for config in vmess vless trojan shadowsocks; do
    wget -q -O "/etc/xray/limit.${config}" "${REPO}ubuntu/${config}"
    chmod +x "/etc/xray/limit.${config}"
done

# Reload systemd to apply changes
systemctl daemon-reload

echo "All services have been installed and started successfully."
