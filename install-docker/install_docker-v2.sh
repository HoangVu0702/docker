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
    elif [[ $ID == "debian"]]; then
      echo "debian"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

# Hàm hiển thị thanh tiến trình
progress_bar() {
  local progress=$1
  local length=$2
  local num_chars=$((progress * length / 100))
  local completed_chars=$((num_chars))
  local remaining_chars=$((length - num_chars))

  local progress_bar="["
  for ((i = 0; i < completed_chars; i++)); do
    progress_bar+="#"
  done

  for ((i = 0; i < remaining_chars; i++)); do
    progress_bar+="."
  done

  progress_bar+="] ($progress%)"
  echo -ne "\rProgress: $progress_bar"
  echo -ne "\n"
}

# Biến tiến trình
installation_progress=0

# Hàm cập nhật tiến trình
update_progress() {
  installation_progress=$1
  progress_bar "$installation_progress" 50
}

# Xác định hệ điều hành
# Xác định hệ điều hành
os=$(detect_os)

if [ "$os" == "ubuntu" ]; then
  echo "Starting the Docker installation process on Ubuntu..."
  apt-get update > /dev/null 2>&1
  update_progress 10
  apt-get install -y ca-certificates curl gnupg > /dev/null 2>&1
  update_progress 20

  install -m 0755 -d /etc/apt/keyrings > /dev/null 2>&1
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
  chmod a+r /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
  update_progress 40

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  update_progress 60

  apt-get update > /dev/null 2>&1
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
  update_progress 100
  echo -ne "\n"

  echo "Docker has been installed on Ubuntu!"

elif [ "$os" == "centos" ]; then
  echo "Starting the Docker installation process on CentOS..."
  yum install -y yum-utils > /dev/null 2>&1
  update_progress 10
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1
  update_progress 50
  yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
  update_progress 100
  echo -ne "\n"

  echo "Docker has been installed on CentOS!"

elif [ "$os" == "debian" ]; then
  # Add Docker's official GPG key:
  apt-get update -y > /dev/null 2>&1
  update_progress 15
  apt-get install ca-certificates curl gnupg -y > /dev/null 2>&1
  update_progress 30
  install -m 0755 -d /etc/apt/keyrings > /dev/null 2>&1
  update_progress 45
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
  update_progress 60
  chmod a+r /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
  update_progress 75
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  update_progress 90
  apt-get update -y > /dev/null 2>&1
  update_progress 100
else
  echo "Unsupported or unknown operating system!"
  exit 1
fi

# Rest of your script...

exit 0
