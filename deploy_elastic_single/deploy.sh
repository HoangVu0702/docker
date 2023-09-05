#!/bin/bash

# Ensure you are running this script as root or with equivalent privileges to configure kernel parameters.
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with equivalent privileges."
  exit 1
fi

# Configure kernel parameters for Elasticsearch
sysctl -w vm.max_map_count=262144

# Save the configuration to /etc/sysctl.conf to apply it automatically on startup
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# Check if the script has enough arguments
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <elastic_version> <elastic_password> <kibana_password> <cluster_name>"
  exit 1
fi

# Retrieve arguments from the command line
ELASTIC_VERSION="$1"
ELASTIC_PASSWORD="$2"
KIBANA_PASSWORD="$3"
CLUSTER_NAME="$4"

# Assign values to environment variables in the .env file for use with Docker Compose
echo "ELASTIC_VERSION=$ELASTIC_VERSION" > .env
echo "ELASTIC_PASSWORD='$ELASTIC_PASSWORD'" >> .env
echo "KIBANA_PASSWORD='$KIBANA_PASSWORD'" >> .env
echo "CLUSTER_NAME='$CLUSTER_NAME'" >> .env

# Pull Elasticsearch and Kibana images from Docker Hub
docker pull docker.elastic.co/elasticsearch/elasticsearch:"$ELASTIC_VERSION"
docker pull docker.elastic.co/kibana/kibana:"$ELASTIC_VERSION"

# Deploy the Elasticsearch and Kibana stack using Docker Compose
docker-compose up -d

# Check if the stack was deployed successfully
if [ $? -eq 0 ]; then
  echo "The Elasticsearch and Kibana stack has been deployed and is running."
else
  echo "Deployment of the Elasticsearch and Kibana stack failed. Please check the logs for more information."
fi
