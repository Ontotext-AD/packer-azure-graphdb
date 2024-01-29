#!/bin/bash

# This script performs the following tasks:
# * Sets the timezone to UTC.
# * Installs necessary tools such as bash-completion, jq, nvme-cli, openjdk-11-jdk, and unzip.
# * Installs the Azure CLI.
# * Creates a system user "graphdb" for GraphDB service.
# * Creates GraphDB directories and sets up the necessary permissions.
# * Downloads and installs GraphDB, configuring systemd for GraphDB and GraphDB proxy.
# * Installs Telegraf for monitoring.
# * Adjusts system settings for keepalive and file max size.
# * Provisions a backup script.
# * Clears authorized_keys files for security.

set -euo pipefail

echo "##############################"
echo "#    Begin Image Creation    #"
echo "##############################"

until ping -c 1 google.com &>/dev/null; do
  echo "Waiting for outbound connectivity"
  sleep 5
done

timedatectl set-timezone UTC

echo "##########################"
echo "#    Installing Tools    #"
echo "##########################"

apt-get -qq -o DPkg::Lock::Timeout=300 update -y
apt-get -qq -o DPkg::Lock::Timeout=300 install -y bash-completion jq nvme-cli openjdk-11-jdk unzip

echo "##############################"
echo "#    Installing Azure CLI    #"
echo "##############################"

curl -sL https://aka.ms/InstallAzureCLIDeb | bash
echo "Azure CLI installed"

echo "###################################"
echo "#    Creating the GraphDB user    #"
echo "###################################"

useradd --comment "GraphDB Service User" --create-home --system --shell /bin/bash --user-group graphdb
echo "User created"

echo "######################################"
echo "#    Creating GraphDB directories    #"
echo "######################################"

mkdir -p /etc/graphdb \
         /etc/graphdb-cluster-proxy \
         /var/opt/graphdb/node \
         /var/opt/graphdb/cluster-proxy

echo "Directories created"

echo "############################################"
echo "#    Downloading and installing GraphDB    #"
echo "############################################"

cd /tmp
curl -O https://maven.ontotext.com/repository/owlim-releases/com/ontotext/graphdb/graphdb/"${GRAPHDB_VERSION}"/graphdb-"${GRAPHDB_VERSION}"-dist.zip

unzip -qq graphdb-"${GRAPHDB_VERSION}"-dist.zip
rm graphdb-"${GRAPHDB_VERSION}"-dist.zip
mv graphdb-"${GRAPHDB_VERSION}" /opt/graphdb-"${GRAPHDB_VERSION}"
ln -s /opt/graphdb-"${GRAPHDB_VERSION}" /opt/graphdb

mv /tmp/graphdb.env /etc/graphdb/graphdb.env

chown -R graphdb:graphdb /etc/graphdb \
                         /etc/graphdb-cluster-proxy \
                         /opt/graphdb \
                         /opt/graphdb-${GRAPHDB_VERSION} \
                         /var/opt/graphdb

echo "GraphDB installed"

echo "###########################################################"
echo "#    Configuring systemd for GraphDB and GraphDB proxy    #"
echo "###########################################################"

mv /tmp/graphdb-cluster-proxy.service /lib/systemd/system/graphdb-cluster-proxy.service
mv /tmp/graphdb.service /lib/systemd/system/graphdb.service

systemctl daemon-reload
systemctl enable graphdb.service
systemctl start graphdb.service

echo "systemd configured"

echo "#############################"
echo "#    Installing Telegraf    #"
echo "#############################"

curl -s https://repos.influxdata.com/influxdata-archive.key > influxdata-archive.key
echo '943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515 influxdata-archive.key' | sha256sum -c && cat influxdata-archive.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
apt-get update && apt-get install telegraf

echo "Telegraf installed"

echo "#############################################"
echo "#    Setting keepalive and file max size    #"
echo "#############################################"

echo 'net.ipv4.tcp_keepalive_time = 120' | tee -a /etc/sysctl.conf
echo 'fs.file-max = 262144' | tee -a /etc/sysctl.conf

sysctl -p

echo "###################################"
echo "#    Provisioning Backup Script   #"
echo "###################################"

mv /tmp/graphdb_backup /usr/bin/graphdb_backup
chmod +x /usr/bin/graphdb_backup
echo "Backup script is provisioned"

echo "###################################"
echo "#    Shredding authorized_keys    #"
echo "###################################"

shred -u /root/.ssh/authorized_keys /home/packer/.ssh/authorized_keys || true
echo "Authorized keys are shredded"

echo "#################################"
echo "#    Image Creation Complete    #"
echo "#################################"
