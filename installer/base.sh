#!/bin/bash
set -e

echo "==> Instalando sistema base"

pacstrap /mnt base linux linux-firmware networkmanager nano sudo git

systemctl enable NetworkManager --root=/mnt
echo "==> Sistema base instalado"