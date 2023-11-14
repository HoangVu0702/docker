#!/bin/bash
clear
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

read -p "Do you want to install Portainer? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
  apt-get install apache2-utils -y
  read -p "Please enter your IP ? " IP
  read -s -p "Please enter the password : " pass
  #docker compose -p portainer up -d
  docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
  echo "Portainer has been installed and started!"
  api_endpoint="https://$IP:9443/api"
  timeout=60
  while ! nc -z -w 1 "$IP" 9443; do
      sleep 5
      timeout=$((timeout - 5))
      if [ "$timeout" -le 0 ]; then
          echo "Timeout while waiting for the container to start."
          exit 1
      fi
  done

  # Check if an Administrator account has been created
  admin_check_status=$(curl -I -s -o --insecure /dev/null -w "%{http_code}" "$api_endpoint/users/admin/check")

  # Configure admin user password
  echo "Configure admin user password...."
  if [ "$admin_check_status" != "200" ] && [ "$admin_check_status" != "204" ]; then
      curl -X POST --insecure -d "{\"Username\": \"admin\", \"Password\": \"$pass\"}" "$api_endpoint/users/admin/init"
  fi
  #echo "Please access to Web check credential https://ip:9443"
else
  echo "Portainer will not be installed."
fi

exit 0
