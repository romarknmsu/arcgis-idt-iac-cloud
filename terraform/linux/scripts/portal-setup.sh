#!/bin/bash
# ArcGIS Portal Setup Script for Linux
# This script prepares the Linux instance for ArcGIS Portal installation

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
    nginx

# Create arcgis user
echo "Creating arcgis user..."
useradd -m -s /bin/bash arcgis || true

# Create installation directories
echo "Creating installation directories..."
mkdir -p /opt/arcgis/portal
mkdir -p /arcgis/portal/usr/arcgisportal
chown -R arcgis:arcgis /opt/arcgis
chown -R arcgis:arcgis /arcgis

# Configure firewall
echo "Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 6443/tcp
ufw allow 7443/tcp
ufw --force enable

# Set hostname
echo "Setting hostname..."
hostnamectl set-hostname arcgis-portal-$ENVIRONMENT

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
EOF
sysctl -p

# Create log directory
mkdir -p /var/log/arcgis
chown arcgis:arcgis /var/log/arcgis

echo "ArcGIS Portal preparation completed!"
echo "Environment: $ENVIRONMENT"
echo "Next steps:"
echo "1. Download ArcGIS Portal installation files"
echo "2. Run the Portal installation wizard"
echo "3. Configure Portal with your organization settings"
