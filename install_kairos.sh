#!/bin/bash
set -e

export KAIROS_PROFILE="none"

echo "==> Configurando KairOS..."
loadkeys la-latin1

run() {
  local script=$1
  echo "==> Ejecutando $script"
  if ! bash "$script"; then
    echo "❌ Error en $script"
    exit 1
  fi
}

run scripts/packages.sh
run scripts/users.sh
run scripts/sudo.sh
run scripts/services.sh
# run scripts/wallpapers.sh
# run scripts/gdm-theme.sh
# run scripts/dconf.sh
# run scripts/extensions.sh
run scripts/os-release.sh
run scripts/firewall.sh
run scripts/conf-hora.sh
echo "==> KairOS configurado."