#!/bin/bash
set -e

echo "=== Instalador KairOS ==="

source installer/detect.sh
source installer/partition.sh
source installer/mount.sh

pacstrap /mnt base linux linux-firmware sudo networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

cp -r /root/KairOS /mnt/root/

arch-chroot /mnt /bin/bash <<EOF
set -e

ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
hwclock --systohc

echo "LANG=es_MX.UTF-8" > /etc/locale.conf
echo "kairos" > /etc/hostname

echo "root:kairos" | chpasswd

cd /root/KairOS
bash install_kairos.sh
bash installer/grub.sh
EOF

echo "Instalación completa"
echo "Reinicia el sistema y retira el medio de instalación."