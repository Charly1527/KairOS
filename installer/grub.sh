#!/bin/bash
set -e

echo "==> Instalando GRUB ($BOOTMODE)"

pacman -S --needed --noconfirm grub efibootmgr os-prober

if [[ "$BOOTMODE" == "UEFI" ]]; then
  grub-install \
    --target=x86_64-efi \
    --efi-directory=/boot/efi \
    --bootloader-id=KairOS \
    --recheck
else
  grub-install --target=i386-pc "$TARGET_DISK"
fi

sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
