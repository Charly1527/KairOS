#!/bin/bash
set -e

echo "==> Instalando fondos de pantalla de KairOS..."

WALL_DIR="/usr/share/backgrounds/kairos"

mkdir -p "$WALL_DIR"
cp /root/KairOS/branding/wallpapers/* "$WALL_DIR/"

chmod 644 "$WALL_DIR"/*

echo "==> Configurando fondo de pantalla por defecto..."

gsettings set org.gnome.desktop.background picture-uri \
"file:///usr/share/backgrounds/kairos/olimpo-white.png"

gsettings set org.gnome.desktop.background picture-uri-dark \
"file:///usr/share/backgrounds/kairos/olimpo-dark.png"