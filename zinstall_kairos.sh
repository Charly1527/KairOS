#!/bin/bash
set -e
echo "==> Actualizando el sistema e instalando paquetes comunes..."
pacman -Syu --noconfirm
pacman -S --noconfirm $(cat /root/KairOS/packages/common.txt)

bash /root/KairOS/scripts/users.sh
bash /root/KairOS/scripts/sudo.sh
bash /root/KairOS/scripts/services.sh
bash /root/KairOS/scripts/firewall.sh
bash /root/KairOS/scripts/conf-hora.sh
bash /root/KairOS/scripts/wallpapers.sh
bash /root/KairOS/scripts/dconf.sh
bash /root/KairOS/scripts/os-release.sh
bash /root/KairOS/scripts/gdm-theme.sh
