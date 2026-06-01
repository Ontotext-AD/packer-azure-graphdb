#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "#########################"
echo "#    IMAGE HARDENING    #"
echo "#########################"

# Install all available updates (incl. security)
apt-get -y full-upgrade
apt-get -y autoremove
apt-get -y clean

cat >/etc/modprobe.d/99-hardening-blocklist.conf <<'EOF'
# Copy Fail
install algif_aead /bin/false
blacklist algif_aead

# Dirty Frag
install esp4 /bin/false
blacklist esp4
install esp6 /bin/false
blacklist esp6
install rxrpc /bin/false
blacklist rxrpc
EOF

for m in algif_aead esp4 esp6 rxrpc; do
  rmmod "$m" 2>/dev/null || true
done

update-initramfs -u -k all
