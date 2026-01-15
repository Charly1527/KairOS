#!/bin/bash
set -e

echo "==> Instalando fondos de pantalla de KairOS..."

DEST="/usr/share/backgrounds/kairos"
XML_DIR="/usr/share/gnome-background-properties"

mkdir -p "$DEST"
mkdir -p "$XML_DIR"

cp /root/KairOS/branding/wallpapers/* "$DEST/"

cat > "$XML_DIR/kairos.xml" <<EOF
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper>
    <name>KairOS Default</name>
    <filename>$DEST/kairos-default.jpg</filename>
    <options>zoom</options>
  </wallpaper>
</wallpapers>
EOF

echo "==> Fondos de pantalla de KairOS instalados correctamente"
