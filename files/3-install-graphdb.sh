#!/bin/bash

# This script performs the following tasks:
# * Creates a system user "graphdb" for GraphDB service.
# * Creates GraphDB directories and sets up the necessary permissions.
# * Downloads and installs GraphDB, configuring systemd for GraphDB and GraphDB proxy.
# * Adjusts system settings for keepalive and file max size.
# * Provisions a backup script.
# * Clears authorized_keys files for security.

set -euo pipefail

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
curl -fsSL -O https://maven.ontotext.com/repository/owlim-releases/com/ontotext/graphdb/graphdb/"${GRAPHDB_VERSION}"/graphdb-"${GRAPHDB_VERSION}"-dist.zip

unzip -qq graphdb-"${GRAPHDB_VERSION}"-dist.zip
rm graphdb-"${GRAPHDB_VERSION}"-dist.zip
mv graphdb-"${GRAPHDB_VERSION}" /opt/graphdb-"${GRAPHDB_VERSION}"
ln -s /opt/graphdb-"${GRAPHDB_VERSION}" /opt/graphdb

mv /tmp/graphdb.env /etc/graphdb/graphdb.env
mv /tmp/graphdb-cluster-proxy.env /etc/graphdb/graphdb-cluster-proxy.env

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

echo "#############################################"
echo "#    Setting keepalive and file max size    #"
echo "#############################################"

echo 'net.ipv4.tcp_keepalive_time = 120' | tee -a /etc/sysctl.conf
echo 'fs.file-max = 262144' | tee -a /etc/sysctl.conf

sysctl -p

echo "keepalive and max file size are configured"

echo "##################################################"
echo "#    Setting Azure Application Insights agent    #"
echo "##################################################"

curl -fsSL -O --output-dir /opt/graphdb/ https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.4.19/applicationinsights-agent-3.4.19.jar
ln -s /opt/graphdb/applicationinsights-agent-3.4.19.jar /opt/graphdb/applicationinsights-agent.jar
chown -R graphdb:graphdb /opt/graphdb/applicationinsights-*.jar

echo "Set up Azure Application Insights agent"

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
