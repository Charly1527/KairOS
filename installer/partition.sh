#!/bin/bash
set -e

echo "==> Particionando $TARGET_DISK"

if [[ "$BOOTMODE" == "UEFI" ]]; then
  parted -s "$TARGET_DISK" mklabel gpt
  parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 513MiB
  parted -s "$TARGET_DISK" set 1 esp on
  parted -s "$TARGET_DISK" mkpart primary ext4 513MiB 100%

  EFI_PART="${TARGET_DISK}1"
  ROOT_PART="${TARGET_DISK}2"

  mkfs.fat -F32 "$EFI_PART"
else
  parted -s "$TARGET_DISK" mklabel msdos
  parted -s "$TARGET_DISK" mkpart primary ext4 1MiB 100%
  ROOT_PART="${TARGET_DISK}1"
fi

mkfs.ext4 -F "$ROOT_PART"

export EFI_PART ROOT_PART
echo "==> Particionamiento completado"