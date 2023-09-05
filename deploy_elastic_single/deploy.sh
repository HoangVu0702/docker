#!/bin/bash

# Ensure you are running this script as root or with equivalent privileges to configure kernel parameters.
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with equivalent privileges."
  exit 1
fi

#Create file store data and config
mkdir es_data certs kib_data logstash_config kib_config
mkdir logstash_config/pipeline
cp config/kibana/* kib_config
cp config/logstash/* logstash_config
cp config/logstash/example.conf logstash_config/pipeline
chmod 777 -R *

echo "DATA_ES=$(pwd)/es_data" >> .env
echo "CERTS=$(pwd)/certs" >> .env
echo "DATA_DASH=$(pwd)/kib_data" >> .env
echo "CONFIG_LOGSTASH=$(pwd)/logstash_config" >> .env
echo "CONFIG_DASH=$(pwd)/kib_config" >> .env

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
