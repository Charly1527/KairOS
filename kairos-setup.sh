#!/bin/bash
set -e

echo "======================================"
echo "   KairOS Beta - Setup Universitario"
echo "   Raspberry Pi OS 64-bit"
echo "   Fecha: $(date)"
echo "   Autor: Chars"
echo "======================================"

echo "======================================"
echo "Verificación root"
echo "======================================"

if [[ $EUID -ne 0 ]]; then
  echo "❌ Ejecuta con sudo"
  exit 1
fi

# -------------------------------
# Variables
# -------------------------------
ADMIN="zeus"
STUDENT="kairos"
TEACHER="hera"

BASE_DIR="$(pwd)"
PKG_DIR="$BASE_DIR/packages"
KAIROS_DIR="/usr/share/kairos"
WALL_DIR="/usr/share/rpd-wallpaper"

USERS=("$ADMIN" "$STUDENT" "$TEACHER")

# -------------------------------
# Funciones
# -------------------------------
phase() {
  echo ""
  echo "▶▶▶ $1"
  echo "--------------------------------------"
}

install_packages_from_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "⚠️ Archivo no encontrado: $file"
    return
  fi

  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

    if apt-cache show "$pkg" &>/dev/null; then
      echo "   ✔ $pkg"
      apt install -y "$pkg"
    else
      echo "   ⚠️ Paquete no disponible: $pkg (omitido)"
    fi
  done < "$file"
}

create_user() {
  local user="$1"
  local groups="$2"
  local pass="$3"

  if ! id "$user" &>/dev/null; then
    echo "Creando usuario $user"
    useradd -m -s /bin/bash -G "$groups" "$user"
    echo "$user:$pass" | chpasswd
  else
    echo "Usuario $user ya existe"
  fi
}

echo "======================================"
echo "FASE 1: Sistema base"
echo "======================================"

phase "Actualizando sistema base"
apt update
apt upgrade -y

echo "======================================"
echo "FASE 1.1: Idioma y localización"
echo "======================================"
# -------------------------------
# FASE X: Idioma y localización (Español MX)
# -------------------------------
phase "Configurando idioma del sistema (Español)"

apt install -y locales locales-all

sed -i 's/^# es_MX.UTF-8 UTF-8/es_MX.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

cat <<EOF > /etc/default/locale
LANG=es_MX.UTF-8
LANGUAGE=es_MX:es_ES:es
LC_ALL=es_MX.UTF-8
EOF

export LANG=es_MX.UTF-8
export LC_ALL=es_MX.UTF-8

# Teclado español latino
cat <<EOF > /etc/default/keyboard
XKBMODEL="pc105"
XKBLAYOUT="latam"
XKBVARIANT=""
XKBOPTIONS=""
EOF

dpkg-reconfigure -f noninteractive keyboard-configuration


echo "======================================"
echo "FASE 2: Paquetes comunes"
echo "======================================"

phase "Instalando paquetes comunes"
apt install -y fastfetch
install_packages_from_file "$PKG_DIR/common.txt"

echo "======================================"
echo "FASE 3: Perfil Universidad"
echo "======================================"

phase "Instalando perfil Universidad"
install_packages_from_file "$PKG_DIR/universidad.txt"

if ! command -v jupyter-lab &>/dev/null; then
  pip3 install --break-system-packages jupyterlab
fi

echo "======================================"
echo "FASE 4: Servicios"  
echo "======================================"

phase "Habilitando servicios"
systemctl enable ssh
systemctl enable cups
systemctl enable avahi-daemon
systemctl enable ufw

ufw default deny incoming || true
ufw default allow outgoing || true
ufw allow ssh || true
ufw --force enable || true

echo "======================================"
echo "FASE 5: Usuarios"
echo "======================================"

phase "Configurando usuarios"

groupadd -f mortales

create_user "$STUDENT" "mortales,audio,video,plugdev" kairos
create_user "$TEACHER" "sudo,audio,video,plugdev" hera
create_user "$ADMIN"   "sudo,audio,video,plugdev" zeus

echo "======================================"
echo "FASE 5.1: Restricción usuario alumno"
echo "======================================"
# -------------------------------
# FASE X: Restricción de usuario alumno
# -------------------------------
phase "Aplicando restricciones al usuario alumno"

STUDENT_HOME="/home/kairos"

# Permisos correctos del home
chmod 750 "$STUDENT_HOME"
chown -R kairos:mortales "$STUDENT_HOME"

# Evitar que liste otros homes
chmod 750 /home

# Asegurar carpetas estándar
sudo -u kairos xdg-user-dirs-update


echo "======================================"
echo "FASE 6: Branding visual"
echo "======================================"

phase "Aplicando branding KairOS"

mkdir -p "$KAIROS_DIR"
cp -r branding/* "$KAIROS_DIR/" || true

cp "$KAIROS_DIR/wallpapers/kairos-wallpaper.jpg" "$WALL_DIR/" || true
cp "$KAIROS_DIR/wallpapers/kairos-login.jpg" "$WALL_DIR/" || true

# Login wallpaper
sed -i "s|^wallpaper=.*|wallpaper=$WALL_DIR/kairos-login.jpg|" \
  /etc/lightdm/pi-greeter.conf || true

# Icono menú
cp "$KAIROS_DIR/icons/kairos-menu.png" \
  /usr/share/lxpanel/images/raspberrypi-menu.png || true

# Splash boot
cp "$KAIROS_DIR/boot/kairos-splash.png" \
  /usr/share/plymouth/themes/pix/splash.png || true
update-initramfs -u

echo "======================================"
echo "FASE 7: Wallpaper por usuario"
echo "======================================"
phase "Configurando wallpaper por usuario"

for u in "${USERS[@]}"; do
  HOME_DIR="/home/$u"
  mkdir -p "$HOME_DIR/.config/pcmanfm/LXDE-pi"

  cat > "$HOME_DIR/.config/pcmanfm/LXDE-pi/desktop-items-0.conf" <<EOF
[*]
wallpaper=$WALL_DIR/kairos-wallpaper.jpg
wallpaper_mode=stretch
desktop_bg=#000000
EOF

  chown -R "$u:$u" "$HOME_DIR/.config"
done

echo "======================================"
echo "FASE 8: Mensaje bienvenida terminal"
echo "======================================"
phase "Configurando bienvenida de terminal"

cat <<'EOF' > /etc/profile.d/kairos-welcome.sh
#!/bin/bash
[[ $- != *i* ]] && return

echo ""
echo "🟦 Bienvenido a KairOS Beta"
echo "Perfil: Universidad"
echo ""
fastfetch
echo ""
EOF

chmod +x /etc/profile.d/kairos-welcome.sh

echo "======================================"
echo "FASE 9: Identidad del sistema"
echo "======================================"
phase "Escribiendo identidad del sistema"

cat <<EOF > /etc/kairos-release
KairOS Beta
Base: Raspberry Pi OS 64-bit
Perfil: Universidad
Fecha: $(date)
EOF

echo ""
echo "======================================"
echo " ✅ KairOS Beta instalado correctamente"
echo "   Gracias por usar KairOS!"
echo " 🔁 Reinicia el sistema"
echo "======================================"
