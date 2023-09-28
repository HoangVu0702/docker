#!/bin/bash

# Kiểm tra xem script được thực thi với đặc quyền root hay không
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

case "$OS" in
    Ubuntu)
        # Gỡ cài đặt Docker trên Ubuntu
        echo "Đang gỡ cài đặt Docker trên Ubuntu..."
        apt-get -y purge docker-ce docker-ce-cli containerd.io
        ;;
    CentOS)
        # Gỡ cài đặt Docker trên CentOS
        echo "Đang gỡ cài đặt Docker trên CentOS..."
        yum -y remove docker-ce docker-ce-cli containerd.io
        ;;
    *)
        echo "Hệ điều hành không được hỗ trợ."
        exit 1
        ;;
esac

# Xóa các tệp và thư mục cài đặt Docker
echo "Đang xóa các tệp và thư mục cài đặt Docker..."
rm -rf /var/lib/docker
rm -rf /etc/docker
rm -rf /etc/systemd/system/docker.service.d
rm -rf /usr/local/bin/docker-compose
rm /etc/apt/keyrings/docker.gpg

# Xóa khóa GPG Docker và các nguồn APT/YUM
echo "Đang xóa khóa GPG Docker và kho lưu trữ gói..."
if [ "$OS" == "Ubuntu" ]; then
    rm /etc/apt/sources.list.d/docker.list
    rm /etc/apt/sources.list.d/docker.list.save
    rm /etc/apt/trusted.gpg.d/docker.gpg
elif [ "$OS" == "CentOS" ]; then
    rm /etc/yum.repos.d/docker-ce.repo
fi

# Cập nhật danh sách gói và làm sạch bộ nhớ cache
echo "Cập nhật danh sách gói và làm sạch bộ nhớ cache..."
if [ "$OS" == "Ubuntu" ]; then
    apt-get update
    apt-get -y autoremove
    apt-get -y clean
elif [ "$OS" == "CentOS" ]; then
    yum -y clean all
fi

echo "Hoàn tất việc gỡ cài đặt Docker và làm sạch cho hệ điều hành $OS."
