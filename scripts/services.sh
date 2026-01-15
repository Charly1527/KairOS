#!/bin/bash
set -e

echo "==> Activando servicios esenciales de KairOS..."

# Login gráfico
systemctl enable gdm.service

# Red
systemctl enable NetworkManager.service

# Impresión
systemctl enable cups.service

# Descubrimiento de red (impresoras, servicios)
systemctl enable avahi-daemon.service

# Bluetooth
systemctl enable bluetooth.service

# Sincronización de hora
systemctl enable systemd-timesyncd.service

# DNS moderno
systemctl enable systemd-resolved.service

# Firewall simple (reglas básicas)
systemctl enable ufw.service

# SSH (opcional, pero recomendado en educación)
systemctl enable sshd.service

echo "==> Servicios activados correctamente"
