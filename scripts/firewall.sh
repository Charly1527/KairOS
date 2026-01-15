#!/bin/bash
set -e

echo "==> Preparando configuración de UFW (se activará en primer arranque)..."

if ! command -v ufw &>/dev/null; then
  echo "UFW no instalado, omitiendo firewall"
  exit 0
fi

ufw default deny incoming
ufw default allow outgoing

if systemctl list-unit-files | grep -q sshd.service; then
  ufw allow ssh
fi

systemctl enable ufw.service

echo "==> Reglas de UFW configuradas (activación diferida)"
