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
echo "==> Servicio de primer arranque instalado."