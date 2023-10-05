# Sử dụng hình ảnh Nginx chính thức làm hình cơ sở
FROM nginx:latest

# Sao chép tệp cấu hình Nginx của bạn vào container
COPY images/nginx/docs.conf /etc/nginx/conf.d/docs.conf
COPY images/nginx/offices.conf /etc/nginx/conf.d/offices.conf

# Tạo một script để thay đổi giá trị server_name dựa trên biến môi trường
COPY images/nginx/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Sử dụng biến môi trường để đặt giá trị server_name
ARG DOMAIN_NC ""
ENV DOMAIN_NC=$DOMAIN_NC
ARG DOMAIN_CODE ""
ENV DOMAIN_CODE=$DOMAIN_CODE

# CMD sẽ thực thi khi container được khởi động
CMD ["/usr/local/bin/entrypoint.sh"]
