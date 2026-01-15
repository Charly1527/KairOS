#!/bin/bash
set -e

cat <<EOF > /etc/os-release
NAME="KairOS"
PRETTY_NAME="KairOS GNU/Linux"
ID=kairos
VERSION="1.0"
VERSION_ID="1.0"
ANSI_COLOR="1;34"
HOME_URL="https://kairos.local"
EOF

echo "KairOS" > /etc/hostname
