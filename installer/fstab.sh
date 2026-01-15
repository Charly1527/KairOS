#!/bin/bash
set -e

echo "==> Generando fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo "==> fstab generado"