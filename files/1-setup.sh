#!/usr/bin/env bash

# This script performs the following tasks:
# * Sets the timezone to UTC.
# * Installs necessary tools such as bash-completion, jq, nvme-cli, openjdk-11-jdk, and unzip.
# * Installs the Azure CLI.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "##############################"
echo "#    Begin Image Creation    #"
echo "##############################"

until ping -c 1 google.com &>/dev/null; do
  echo "waiting for outbound connectivity"
  sleep 5
done

timedatectl set-timezone UTC

echo "##########################"
echo "#    Installing Tools    #"
echo "##########################"

apt-get -qq update
apt-get -qq install -y ca-certificates gnupg

# Temurin setup
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
mkdir -p /etc/apt/keyrings
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc

# Install Tools
apt-get -qq -o DPkg::Lock::Timeout=300 update -y
apt-get -qq -o DPkg::Lock::Timeout=300 install -y bash-completion jq nvme-cli temurin-21-jdk unzip

echo "##############################"
echo "#    Installing Azure CLI    #"
echo "##############################"

curl -sL https://aka.ms/InstallAzureCLIDeb | bash
echo "Azure CLI installed"
