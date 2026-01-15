#!/bin/bash
set -e

PACKAGE_DIR="/root/KairOS/packages"
PROFILE="${KAIROS_PROFILE:-none}"

echo "==> Perfil educativo seleccionado: $PROFILE"

pacman -Syu --noconfirm

# Paquetes comunes (siempre)
pacman -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/common.txt")

# Arquitectura
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" && -f "$PACKAGE_DIR/x86_64.txt" ]]; then
  pacman -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/x86_64.txt")
elif [[ "$ARCH" == "aarch64" && -f "$PACKAGE_DIR/aarch64.txt" ]]; then
  pacman -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/aarch64.txt")
fi

# Perfiles educativos
case "$PROFILE" in
  none)           LEVELS=() ;;
  primaria)       LEVELS=("primaria") ;;
  secundaria)     LEVELS=("secundaria") ;;
  bachillerato)   LEVELS=("bachillerato") ;;
  universidad)    LEVELS=("universidad") ;;
  todos|*)        LEVELS=("primaria" "secundaria" "bachillerato" "universidad") ;;
esac

for nivel in "${LEVELS[@]}"; do
  FILE="$PACKAGE_DIR/$nivel.txt"
  if [[ -f "$FILE" ]]; then
    echo "==> Instalando paquetes: $nivel"
    pacman -S --needed --noconfirm $(grep -v '^#' "$FILE")
  fi
done

# AUR
if [[ -f "$PACKAGE_DIR/aur.txt" ]]; then
  if ! command -v yay &>/dev/null; then
    useradd -m builder
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    su - builder -c "
      git clone https://aur.archlinux.org/yay.git
      cd yay
      makepkg -si --noconfirm
    "

    userdel -r builder
  fi

  yay -S --needed --noconfirm $(grep -v '^#' "$PACKAGE_DIR/aur.txt")
fi

echo "==> Paquetes instalados correctamente"
