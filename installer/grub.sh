#!/bin/bash
set -e

pacman -S --noconfirm grub efibootmgr

grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=KairOS

grub-mkconfig -o /boot/grub/grub.cfg
echo "==> GRUB instalado y configurado"