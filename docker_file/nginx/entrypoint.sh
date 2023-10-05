#!/bin/sh
# Thay đổi giá trị server_name trong tệp cấu hình
sed -i "s/server_name example.com;/server_name $DOMAIN_NC;/g" /etc/nginx/conf.d/docs.conf
sed -i "s/server_name example.com;/server_name $DOMAIN_CODE;/g" /etc/nginx/conf.d/offices.conf
# Khởi động Nginx
nginx -g "daemon off;"
