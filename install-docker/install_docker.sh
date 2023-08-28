#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Script cần chạy với quyền root!"
  exit 1
fi

if [ "$1" = "Ubuntu" ]; then
  echo "Bắt đầu quá trình cài đặt Docker trên Ubuntu..."
  apt-get update
  apt-get install -y ca-certificates curl gnupg

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Đã cài đặt Docker trên Ubuntu!"

elif [ "$1" = "CentOS" ]; then
  echo "Bắt đầu quá trình cài đặt Docker trên CentOS..."
  yum install -y yum-utils
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Đã cài đặt Docker trên CentOS!"

else
  echo "Hệ điều hành không hỗ trợ hoặc sai tham số!"
  echo "Sử dụng: sudo bash install_docker.sh Ubuntu hoặc sudo bash install_docker.sh CentOS"
  exit 1
fi
read -p "Bạn có muốn cài đặt Portainer không? (y/n): " choice
if [ "$choice" = "y" ]; then
  docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
  echo "Đã cài đặt và chạy Portainer!"
else
  echo "Không cài đặt Portainer."
fi
exit 0
