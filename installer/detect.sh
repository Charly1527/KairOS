#!/bin/bash
set -e

echo "==> Detectando entorno de arranque..."

if [ -d /sys/firmware/efi ]; then
  BOOTMODE="UEFI"
else
  BOOTMODE="BIOS"
fi

DISKS=($(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}'))

if [ ${#DISKS[@]} -eq 0 ]; then
  echo "❌ No se detectaron discos"
  exit 1
fi

TARGET_DISK="${DISKS[0]}"

echo "Modo de arranque: $BOOTMODE"
echo "Disco seleccionado: $TARGET_DISK"

export BOOTMODE TARGET_DISK

echo "==> Entorno de arranque detectado correctamente"