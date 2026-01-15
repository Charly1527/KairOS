#!/bin/bash
set -e

echo "==> Instalando fondo de GDM (branding)..."

mkdir -p /usr/share/backgrounds/kairos
cp /root/KairOS/branding/gdm/gdm-bg.png /usr/share/backgrounds/kairos/

echo "==> Fondo de GDM instalado (sin modificar CSS)"
