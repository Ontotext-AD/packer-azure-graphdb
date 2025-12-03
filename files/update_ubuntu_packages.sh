#!/bin/bash
set -euo pipefail

# Refresh package lists
apt-get update

# Install all available updates (incl. security)
apt-get -y dist-upgrade

# Cleanup to shrink the image
apt-get -y autoremove --purge
apt-get -y clean
