#!/bin/bash

# Warna untuk output
RED='\e[31m'
GREEN='\e[32m'
PURPLE='\e[35m'
ORANGE='\e[33m'
NC='\e[0m' # No Color

clear
echo -e "${GREEN}Installing TCP BBR Powered by CHAPEEY${NC}"
echo -e "Please wait, BBR installation will start soon..."
sleep 5
clear

# Fungsi untuk menambahkan baris baru jika diperlukan
Add_To_New_Line() {
  if [ "$(tail -n1 "$1" | wc -l)" -eq 0 ]; then
    echo "" >> "$1"
  fi
  echo "$2" >> "$1"
}

# Fungsi untuk memeriksa dan menambahkan konfigurasi
Check_And_Add_Line() {
  if ! grep -q "$2" "$1"; then
    Add_To_New_Line "$1" "$2"
  fi
}

# Instalasi BBR
Install_BBR() {
  echo -e "${PURPLE}Installing TCP BBR...${NC}"
  if lsmod | grep -q bbr; then
    echo -e "${GREEN}TCP BBR is already installed.${NC}"
    return 0
  fi

  modprobe tcp_bbr
  Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
  Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc=fq"
  Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control=bbr"
  sysctl -p

  if sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr && \
     sysctl net.ipv4.tcp_congestion_control | grep -q bbr && \
     lsmod | grep -q "tcp_bbr"; then
    echo -e "${GREEN}TCP BBR installed successfully!${NC}"
  else
    echo -e "${RED}Failed to install TCP BBR.${NC}"
  fi
}

# Optimasi parameter jaringan
Optimize_Parameters() {
  echo -e "${PURPLE}Optimizing network parameters...${NC}"
  modprobe ip_conntrack

  Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 65535"
  Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 65535"
  Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
  Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"

  Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_forward=1"
  Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max=16777216"
  Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max=16777216"
  Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_window_scaling=1"
  Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies=1"

  sysctl -p
  echo -e "${GREEN}Network parameters optimized successfully.${NC}"
}

# Eksekusi fungsi
Install_BBR
Optimize_Parameters

# Hapus skrip setelah instalasi selesai
rm -f /root/bbr.sh >/dev/null 2>&1

echo -e "${GREEN}Installation complete!${NC}"
sleep 3
