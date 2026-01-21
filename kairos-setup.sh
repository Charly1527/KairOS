#!/bin/bash
set -e

echo "======================================"
echo "   KairOS Beta - Setup Universitario"
echo "   Raspberry Pi OS 64-bit"
echo "======================================"

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta con sudo"
  exit 1
fi

ADMIN="zeus"
STUDENT="kairos"
TEACHER="hera"

BASE_DIR="$(pwd)"
PKG_DIR="$BASE_DIR/packages"

# --------------------------------
# Sistema base
# --------------------------------
apt update
apt upgrade -y

# --------------------------------
# Instalar paquetes comunes
# --------------------------------
echo "==> Instalando paquetes comunes..."
xargs -a "$PKG_DIR/common.txt" apt install -y

# --------------------------------
# Perfil Universidad
# --------------------------------
echo "==> Instalando perfil Universidad..."
xargs -a "$PKG_DIR/universidad.txt" apt install -y
pip3 install --break-system-packages jupyterlab

# --------------------------------
# Servicios
# --------------------------------
systemctl enable ssh
systemctl enable cups
systemctl enable avahi-daemon
systemctl enable ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

# --------------------------------
# Usuarios
# --------------------------------
groupadd -f mortales

create_user() {
  if ! id "$1" &>/dev/null; then
    useradd -m -s /bin/bash -G "$2" "$1"
    echo "$1:$3" | chpasswd
  fi
}

create_user "$STUDENT" "mortales,audio,video,plugdev" kairos
create_user "$TEACHER" "sudo,audio,video,plugdev" hera

# --------------------------------
# Branding visual
# --------------------------------
WALL="/usr/share/rpd-wallpaper"

cp branding/wallpapers/kairos-wallpaper.jpg "$WALL/" || true
cp branding/wallpapers/kairos-login.jpg "$WALL/" || true

sed -i "s|^wallpaper=.*|wallpaper=$WALL/kairos-login.jpg|" \
  /etc/lightdm/pi-greeter.conf || true

cp branding/icons/kairos-menu.png \
  /usr/share/lxpanel/images/raspberrypi-menu.png || true

cp branding/boot/kairos-splash.png \
  /usr/share/plymouth/themes/pix/splash.png || true
update-initramfs -u

# --------------------------------
# Modo oscuro + universidad
# --------------------------------
for u in "$ADMIN" "$STUDENT" "$TEACHER"; do
  sudo -u "$u" dbus-launch gsettings set \
    org.gnome.desktop.interface color-scheme 'prefer-dark' || true
done

for u in "$ADMIN" "$TEACHER"; do
  sudo -u "$u" dbus-launch gsettings set \
    org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' || true
done

# --------------------------------
# MOTD + neofetch
# --------------------------------
cat <<EOF > /etc/motd
========================================
   Bienvenido a KairOS Beta
   Perfil: Universidad
========================================
EOF

cat <<'EOF' > /etc/profile.d/kairos.sh
#!/bin/bash
neofetch
EOF
chmod +x /etc/profile.d/kairos.sh

# --------------------------------
# Identidad
# --------------------------------
cat <<EOF > /etc/kairos-release
KairOS Beta
Base: Raspberry Pi OS 64-bit
Perfil: Universidad
Fecha: $(date)
EOF

echo "======================================"
echo " KairOS listo. Reinicia el sistema."
echo "======================================"
