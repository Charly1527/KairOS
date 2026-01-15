#!/bin/bash
set -e

echo "==> Montando sistema"

mount "$ROOT_PART" /mnt

if [[ "$BOOTMODE" == "UEFI" ]]; then
  mkdir -p /mnt/boot/efi
  mount "$EFI_PART" /mnt/boot/efi
fi
echo "==> Sistema montado correctamente"