#!/bin/bash
# ArcGIS Server Setup Script for Linux
# This script prepares the Linux instance for ArcGIS Server installation

set -e

ENVIRONMENT="${environment}"

# Update system
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y \
    wget \
    curl \
    unzip \
    python3 \
    python3-pip \
    openjdk-11-jdk \
    fontconfig \
    libfreetype6 \
    libfontconfig1

# Create arcgis user
echo "Creating arcgis user..."
useradd -m -s /bin/bash arcgis || true

# Create installation directories
echo "Creating installation directories..."
mkdir -p /opt/arcgis/server
mkdir -p /arcgis/server/usr/arcgisserver
mkdir -p /arcgis/server/directories
chown -R arcgis:arcgis /opt/arcgis
chown -R arcgis:arcgis /arcgis

# Configure firewall
echo "Configuring firewall..."
ufw allow 22/tcp
ufw allow 6080/tcp
ufw allow 6443/tcp
ufw --force enable

# Set hostname
echo "Setting hostname..."
hostnamectl set-hostname arcgis-server-$ENVIRONMENT

# Configure system limits
echo "Configuring system limits..."
cat >> /etc/security/limits.conf << 'EOF'
arcgis soft nofile 65535
arcgis hard nofile 65535
arcgis soft nproc 25059
arcgis hard nproc 25059
EOF

# Configure kernel parameters
echo "Configuring kernel parameters..."
cat >> /etc/sysctl.conf << 'EOF'
vm.max_map_count = 262144
vm.swappiness = 1
net.ipv4.tcp_keepalive_time = 300
EOF
sysctl -p

# Create log directory
mkdir -p /var/log/arcgis
chown arcgis:arcgis /var/log/arcgis

# Install fonts for map rendering
echo "Installing fonts..."
apt-get install -y fonts-liberation fonts-dejavu

echo "ArcGIS Server preparation completed!"
echo "Environment: $ENVIRONMENT"
echo "Next steps:"
echo "1. Download ArcGIS Server installation files"
echo "2. Run the Server installation wizard"
echo "3. Create and authorize a Server site"
