#!/bin/bash
set -e

echo "=== Instalador KairOS ==="

bash installer/disk.sh
bash installer/base.sh
bash installer/fstab.sh

echo "==> Copiando KAIROS al sistema instalado"
cp -r /root/KairOS /mnt/root/

arch-chroot /mnt /bin/bash <<'EOF'
set -e

ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
hwclock --systohc

echo "LANG=es_MX.UTF-8" > /etc/locale.conf
echo "kairOS" > /etc/hostname

cd /root/KairOS

bash install_kairos.sh
bash installer/grub.sh
EOF

echo "Instalación finalizada"
echo "Reinicia el sistema y retira el medio de instalación."
