#!/bin/bash
set -e

echo "==> Instalando fondos de pantalla de KairOS..."

DEST="/usr/share/backgrounds/kairos"
mkdir -p "$DEST"

cp /root/KairOS/branding/wallpapers/* "$DEST/"

cat > /usr/share/gnome-background-properties/kairos.xml <<EOF
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper>
    <name>KairOS Default</name>
    <filename>$DEST/olimpo-dark.png</filename>
    <options>zoom</options>
  </wallpaper>
</wallpapers>
EOF

echo "==> Fondos instalados correctamente"
