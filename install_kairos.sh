#!/bin/bash
set -e

export KAIROS_PROFILE="none"

echo "==> Configurando KairOS..."
loadkeys la-latin1
bash scripts/packages.sh
bash scripts/users.sh
bash scripts/sudo.sh
bash scripts/services.sh
bash scripts/wallpapers.sh
bash scripts/gdm-theme.sh
bash scripts/dconf.sh
bash scripts/extensions.sh
bash scripts/os-release.sh
bash scripts/firewall.sh
bash scripts/conf-hora.sh
