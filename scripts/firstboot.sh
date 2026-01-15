#!/bin/bash
set -e

USER="kairos"
FLAG="/var/lib/kairos-firstboot.done"

[ -f "$FLAG" ] && exit 0

echo "==> Primer arranque de KairOS"

# Esperar entorno gráfico
sleep 5

# DBus seguro
export XDG_RUNTIME_DIR="/run/user/$(id -u $USER)"

sudo -u "$USER" dbus-launch gsettings set \
  org.gnome.desktop.background picture-uri \
  "file:///usr/share/backgrounds/gnome/adwaita-l.webp"

# Ajustes base
sudo -u "$USER" dbus-launch gsettings set \
  org.gnome.desktop.interface clock-format '24h'

touch "$FLAG"
echo "==> Configuración de primer arranque completada"