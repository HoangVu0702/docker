#!/bin/bash
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
STACK_VERSION="$1"
ELASTIC_PASSWORD="$2"

# Gán các giá trị vào tệp .env
echo "STACK_VERSION=$STACK_VERSION" > .env
echo "ELASTIC_PASSWORD=$ELASTIC_PASSWORD" >> .env

docker pull docker.elastic.co/elasticsearch/elasticsearch:"$STACK_VERSION"
docker pull docker.elastic.co/kibana/kibana:"$STACK_VERSION"
docker-compose up -d
