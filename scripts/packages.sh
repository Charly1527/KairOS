#!/bin/bash
set -e

PACKAGE_DIR="/root/KairOS/packages"
PROFILE="${KAIROS_PROFILE:-universidad}"

echo "==> Perfil educativo seleccionado: $PROFILE"

pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm

echo "==> Instalando paquetes comunes"
pacman -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/common.txt")

ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" && -f "$PACKAGE_DIR/x86_64.txt" ]]; then
  pacman -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/x86_64.txt")
elif [[ "$ARCH" == "aarch64" && -f "$PACKAGE_DIR/aarch64.txt" ]]; then
  pacman -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/aarch64.txt")
fi

case "$PROFILE" in
  none) LEVELS=() ;;
  primaria|secundaria|bachillerato|universidad)
    LEVELS=("$PROFILE") ;;
  *) LEVELS=("primaria" "secundaria" "bachillerato" "universidad") ;;
esac

for nivel in "${LEVELS[@]}"; do
  FILE="$PACKAGE_DIR/$nivel.txt"
  if [[ -f "$FILE" ]]; then
    pacman -S --needed --noconfirm $(grep -v '^#' "$FILE")
  fi
done

echo "==> Paquetes instalados correctamente"
