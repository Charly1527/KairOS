#!/bin/bash
echo "==> Copiando el fondo de pantalla de GDM..."
mkdir -p /usr/share/backgrounds/gdm
cp /root/KairOS/branding/gdm/gdm-bg.jpg /usr/share/backgrounds/gdm/

set -e

echo "==> Configurando fondo de GDM..."

GDM_CONF="/usr/share/gnome-shell/theme/gdm3.css"

if ! grep -q "KairOS" "$GDM_CONF"; then
  cat <<EOF >> "$GDM_CONF"

/* KairOS Branding */
#lockDialogGroup {
  background: #000000 url("/usr/share/backgrounds/gdm/gdm-bg.png");
  background-size: cover;
}
EOF
fi
