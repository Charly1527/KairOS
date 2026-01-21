#!/bin/bash
set -e

export KAIROS_PROFILE="universidad"

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
run scripts/wallpapers.sh
run scripts/gdm-theme.sh
# run scripts/dconf.sh
# run scripts/extensions.sh
run scripts/os-release.sh
# run scripts/firewall.sh
run scripts/conf-hora.sh
echo "==> KairOS configurado."
echo "==> Instalando servicio de primer arranque..."

cat > /etc/systemd/system/kairos-firstboot.service << 'EOF'
[Unit]
Description=KairOS First Boot Configuration
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/kairos-firstboot.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

cat > /usr/local/bin/kairos-firstboot.sh << 'EOF'
#!/bin/bash
set -e

LOG="/var/log/kairos-firstboot.log"

echo "==> Primer arranque de KairOS" | tee -a "$LOG"

if command -v ufw &>/dev/null; then
  ufw --force enable || true
fi

touch /etc/kairos-firstboot.done
systemctl disable kairos-firstboot.service
EOF

chmod +x /usr/local/bin/kairos-firstboot.sh
systemctl enable kairos-firstboot.service

echo "==> Configurando primer login de KairOS..."

cat > /usr/local/bin/kairos-first-login.sh << 'EOF'
#!/bin/bash
set -e

FLAG="$HOME/.config/.kairos-first-login-done"

if [ -f "$FLAG" ]; then
  exit 0
fi

gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/kairos/kairos-default.jpg"

touch "$FLAG"
EOF

chmod +x /usr/local/bin/kairos-first-login.sh

mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/kairos-first-login.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=KairOS First Login Setup
Exec=/usr/local/bin/kairos-first-login.sh
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

echo "==> Servicio de primer arranque instalado."