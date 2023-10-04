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

# Hàm giả lập tiến trình
simulate_progress() {
  local job_name="$1"
  local total_steps="$2"
  local current_step=0
  while [ $current_step -lt $total_steps ]; do
    sleep 1
    current_step=$((current_step + 1))
    percentage=$((current_step * 100 / total_steps))
    echo "[$job_name] Progress: $percentage%"
  done
}

# Xác định hệ điều hành
os=$(detect_os)

if [ "$os" == "ubuntu" ]; then
  echo "Starting the Docker installation process on Ubuntu..."
  simulate_progress "Install Docker" 10
  apt-get update >/dev/null 2>&1
  apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1

  install -m 0755 -d /etc/apt/keyrings >/dev/null 2>&1
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg >/dev/null 2>&1
  chmod a+r /etc/apt/keyrings/docker.gpg >/dev/null 2>&1

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update >/dev/null 2>&1


  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1

  echo "Docker has been installed on Ubuntu!"

elif [ "$os" == "centos" ]; then
  echo "Starting the Docker installation process on CentOS..."
  # Giả lập tiến trình cài đặt Docker
  simulate_progress "Install Docker" 10
  yum install -y yum-utils >/dev/null 2>&1
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >/dev/null 2>&1

  yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1

  echo "Docker has been installed on CentOS!"

else
  echo "Unsupported or unknown operating system!" >/dev/null 2>&1
  exit 1
fi

read -p "Do you want to install Portainer? (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
  apt-get install apache2-utils -y >/dev/null 2>&1
  read -s -p "Please enter the password : " pass
  echo

  pass_por=$(htpasswd -nb -B admin $pass | cut -d ":" -f 2)
  if grep -q "PASS_POR" source/.env; then
    echo "Nothing" >/dev/null 2>&1
  else
      echo "PASS_POR='$pass_por'" >> source/.env
      echo "PASS_POR_GUI=$pass" >> source/.env
  fi
  # Giả lập tiến trình cài đặt Portainer
  simulate_progress "Install Portainer" 5
  # Sử dụng nohup để chạy Portainer trong nền và ẩn đầu ra và lỗi
  docker compose -p portainer -f source/docker-compose-por.yml up -d >/dev/null 2>&1

  echo "Portainer has been installed and started!"
else
  echo "Portainer will not be installed." >/dev/null 2>&1
fi

exit 0
