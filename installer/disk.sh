#!/bin/bash
set -e

DISK="/dev/vda"   # luego lo hacemos dinámico

echo "==> Particionando disco $DISK"

sgdisk --zap-all $DISK

sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" $DISK
sgdisk -n 2:0:0     -t 2:8300 -c 2:"ROOT" $DISK

mkfs.fat -F32 ${DISK}1
mkfs.ext4 ${DISK}2

mount ${DISK}2 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

echo "==> Disco listo"
