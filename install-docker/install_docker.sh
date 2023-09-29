#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges!"
  exit 1
fi

# Hàm để xác định hệ điều hành
detect_os() {
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ $ID == "ubuntu" || $ID_LIKE == "debian" ]]; then
      echo "ubuntu"
    elif [[ $ID == "centos" || $ID == "rhel" || $ID == "fedora" ]]; then
      echo "centos"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

# Xác định hệ điều hành
os=$(detect_os)

if [ "$os" == "ubuntu" ]; then
  echo "Starting the Docker installation process on Ubuntu..."
  apt-get update
  apt-get install -y ca-certificates curl gnupg

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Docker has been installed on Ubuntu!"

elif [ "$os" == "centos" ]; then
  echo "Starting the Docker installation process on CentOS..."
  yum install -y yum-utils
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Docker has been installed on CentOS!"

else
  echo "Unsupported or unknown operating system!"
  exit 1
fi

#!/bin/bash
read -p "Bạn có muốn cài đặt Portainer không? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    read -p "Please enter the password : " pass
    pass_por=$(htpasswd -nb -B admin $pass | cut -d ":" -f 2)
    echo "PASS_POR=$pass_por" > .env
    #docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --admin-password $pass_por portainer/portainer-ce:latest
    docker compose -p portainer up -d
    echo "Portainer đã được cài đặt và khởi động!"
else
    echo "Portainer sẽ không được cài đặt."
fi

exit 0
