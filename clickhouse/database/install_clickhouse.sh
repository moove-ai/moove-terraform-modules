#!/usr/bin/env bash

FILE_PATH="/var/admin/clickhouse/init"

# Check if the file exists
if [[ -f $FILE_PATH ]]; then
    echo "Init file already exists. Exiting script."
    exit 0
fi

# Update and install necessary tools
apt-get update
apt-get install -y apt-transport-https dirmngr

# Add ClickHouse repository
echo "deb https://repo.clickhouse.tech/deb/stable/ main/" | tee /etc/apt/sources.list.d/clickhouse.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4

# Install ClickHouse
apt-get update
apt-get install -y clickhouse-server clickhouse-client

# Start ClickHouse
systemctl start clickhouse-server
