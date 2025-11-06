#!/bin/bash
set -e

# Update system
yum update -y

# Install prerequisites
yum install -y \
    python3 \
    python3-pip \
    wget \
    curl \
    unzip \
    git \
    openssl \
    java-11-openjdk \
    dos2unix

# Install AWS CLI
pip3 install awscli --upgrade

# Create directories
mkdir -p /opt/arcgis/installer
mkdir -p /opt/arcgis/software
mkdir -p /var/log/arcgis-install

# Set environment variables
echo "export ARCGIS_VERSION=${arcgis_version}" >> /etc/environment
echo "export S3_BUCKET=${s3_bucket_name}" >> /etc/environment
echo "export PROJECT_NAME=${project_name}" >> /etc/environment

# Log the instance is ready for configuration
echo "$(date): Linux instance initialized and ready for Ansible configuration" >> /var/log/arcgis-install/init.log

# Create a marker file to indicate initialization is complete
touch /var/lib/cloud/instance/user-data-completed
