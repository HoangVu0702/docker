#!/bin/bash

# Ensure you are running this script as root or with equivalent privileges to configure kernel parameters.
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with equivalent privileges."
  exit 1
fi

# Install package need
apt install unzip

#Create file store data and config
mkdir his-cybersoc-logs-data his-cybersoc-logs-config certs his-cybersoc-kibana-data his-cybersoc-logstash-config his-cybersoc-kibana-config
mkdir his-cybersoc-logstash-config/pipeline
cp config/kibana/* his-cybersoc-kibana-config
cp config/logstash/* his-cybersoc-logstash-config
unzip config/elasticsearch/his-cybersoc-logs-config.zip
cp config/logstash/example.conf his-cybersoc-logstash-config/pipeline
chmod 777 -R *

echo "DATA_ES=$(pwd)/his-cybersoc-logs-data" >> .env
echo "CERTS=$(pwd)/certs" >> .env
echo "DATA_DASH=$(pwd)/his-cybersoc-kibana-data" >> .env
echo "CONFIG_LOGSTASH=$(pwd)/his-cybersoc-logstash-config" >> .env
echo "CONFIG_DASH=$(pwd)/his-cybersoc-kibana-config" >> .env
echo "CONFIG_ES=$(pwd)/his-cybersoc-logs-config" >> .env

# Configure kernel parameters for Elasticsearch
sysctl -w vm.max_map_count=262144

# Save the configuration to /etc/sysctl.conf to apply it automatically on startup
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# Check if the script has enough arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <elastic_version> <stack_name>"
  exit 1
fi

# Retrieve arguments from the command line
STACK_VERSION="$1"
PROJECT_NAME="$2"

echo "STACK_VERSION=$STACK_VERSION" >> .env

# Pull Elasticsearch and Kibana images from Docker Hub
docker pull docker.elastic.co/elasticsearch/elasticsearch:"$STACK_VERSION"
docker pull docker.elastic.co/kibana/kibana:"$STACK_VERSION"
docker pull docker.elastic.co/logstash/logstash:"$STACK_VERSION"

#Create Network
docker network create siem_net

# Deploy the Elasticsearch and Kibana stack using Docker Compose
docker compose -p "$PROJECT_NAME" up -d
# Check if the stack was deployed successfully
if [ $? -eq 0 ]; then
  echo "The Elasticsearch and Kibana stack has been deployed and is running."
else
  echo "Deployment of the Elasticsearch and Kibana stack failed. Please check the logs for more information."
fi
