#!/bin/bash
set -e

echo "=== Instalador KairOS ==="

bash installer/disk.sh
bash installer/base.sh
bash installer/fstab.sh

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
hwclock --systohc
echo "LANG=es_MX.UTF-8" > /etc/locale.conf
echo "kairOS" > /etc/hostname

bash /root/KAIROS/install_kairos.sh
bash installer/grub.sh
EOF

echo "Instalación finalizada. Reinicia."
echo "No olvides desmontar las particiones y retirar el medio de instalación."
echo "Puedes reiniciar con: systemctl reboot"