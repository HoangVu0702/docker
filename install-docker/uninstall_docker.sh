#!/bin/bash

# Kiểm tra xem script được thực thi với quyền root hay không
if [ "$EUID" -ne 0 ]; then
    echo "Vui lòng chạy script này với quyền root (sudo)."
    exit 1
fi

# Xác định hệ điều hành
if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ $ID == "ubuntu" || $ID_LIKE == "debian" ]]; then
        OS="Ubuntu"
    elif [[ $ID == "centos" || $ID == "rhel" || $ID == "fedora" ]]; then
        OS="CentOS"
    else
        echo "Hệ điều hành không được hỗ trợ."
        exit 1
    fi
else
    echo "Không thể xác định hệ điều hành."
    exit 1
fi

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

# Bắt đầu giả lập tiến trình
simulate_progress "Gỡ cài đặt Docker" 5

case "$OS" in
    Ubuntu)
        # Gỡ cài đặt Docker trên Ubuntu và ẩn thông tin chi tiết
        echo "[$job_name] Đang gỡ cài đặt Docker trên Ubuntu..."
        apt-get -y purge docker-ce docker-ce-cli containerd.io > /dev/null 2>&1
        ;;
    CentOS)
        # Gỡ cài đặt Docker trên CentOS và ẩn thông tin chi tiết
        echo "[$job_name] Đang gỡ cài đặt Docker trên CentOS..."
        yum -y remove docker-ce docker-ce-cli containerd.io > /dev/null 2>&1
        ;;
    *)
        echo "Hệ điều hành không được hỗ trợ."
        exit 1
        ;;
esac

# Tiếp tục giả lập tiến trình
simulate_progress "Xóa tệp và thư mục cài đặt" 5

# Xóa các tệp và thư mục cài đặt Docker và ẩn thông tin chi tiết
echo "[$job_name] Đang xóa các tệp và thư mục cài đặt Docker..."
rm -rf /var/lib/docker > /dev/null 2>&1
rm -rf /etc/docker > /dev/null 2>&1
rm -rf /etc/systemd/system/docker.service.d > /dev/null 2>&1
rm -rf /usr/local/bin/docker-compose > /dev/null 2>&1
rm /etc/apt/keyrings/docker.gpg > /dev/null 2>&1

# Tiếp tục giả lập tiến trình
simulate_progress "Xóa khóa GPG và nguồn APT/YUM" 5

# Xóa khóa GPG Docker và các nguồn APT/YUM và ẩn thông tin chi tiết
echo "[$job_name] Đang xóa khóa GPG Docker và kho lưu trữ gói..."
if [ "$OS" == "Ubuntu" ]; then
    rm /etc/apt/sources.list.d/docker.list > /dev/null 2>&1
    rm /etc/apt/sources.list.d/docker.list.save > /dev/null 2>&1
    rm /etc/apt/trusted.gpg.d/docker.gpg > /dev/null 2>&1
    rm /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
    rm /etc/apt/sources.list.d/docker.list > /dev/null 2>&1
elif [ "$OS" == "CentOS" ]; then
    rm /etc/yum.repos.d/docker-ce.repo > /dev/null 2>&1
fi

# Tiếp tục giả lập tiến trình
simulate_progress "Cập nhật danh sách gói và làm sạch bộ nhớ cache" 5

# Cập nhật danh sách gói và làm sạch bộ nhớ cache và ẩn thông tin chi tiết
echo "[$job_name] Cập nhật danh sách gói và làm sạch bộ nhớ cache..."
if [ "$OS" == "Ubuntu" ]; then
    apt-get update > /dev/null 2>&1
    apt-get -y autoremove > /dev/null 2>&1
    apt-get -y clean > /dev/null 2>&1
elif [ "$OS" == "CentOS" ]; then
    yum -y clean all > /dev/null 2>&1
fi

# Tiếp tục giả lập tiến trình
simulate_progress "Hoàn tất gỡ cài đặt Docker" 5

echo "Hoàn tất việc gỡ cài đặt Docker và làm sạch cho hệ điều hành $OS."
