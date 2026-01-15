#!/bin/bash
# install-gnome-extensions-basic.sh
set -e

EXT_DIR="/usr/share/gnome-shell/extensions"
mkdir -p "$EXT_DIR"

echo "==> Instalando extensiones para GNOME..."

# 1. Dash to Dock v89
git clone --depth 1 --branch v89 \
    https://github.com/micheleg/dash-to-dock.git \
    "$EXT_DIR/dash-to-dock@micxgx.gmail.com"

# 2. Just Perfection v56  
git clone --depth 1 --branch v56 \
    https://github.com/just-perfection/JustPerfection.git \
    "$EXT_DIR/just-perfection-desktop@just-perfection"

# 3. Lock Keys v67
LOCK_URL="https://extensions.gnome.org/extension-data/lockkeysvaina.lt.v67.shell-extension.zip"
wget -q -O /tmp/lockkeys.zip "$LOCK_URL"
mkdir -p "$EXT_DIR/lockkeys@vaina.lt"
unzip -q /tmp/lockkeys.zip -d "$EXT_DIR/lockkeys@vaina.lt/"
rm /tmp/lockkeys.zip

# 4. Burn My Windows v47
git clone --depth 1 https://github.com/Schneegans/Burn-My-Windows.git \
    /tmp/burn-my-windows
cd /tmp/burn-my-windows

# Instalar dependencias y compilar
if command -v npm &> /dev/null; then
    npm install --no-audit --no-fund
    npm run compile
fi

mkdir -p "$EXT_DIR/burn-my-windows@schneegans.github.com"
cp -r src/* "$EXT_DIR/burn-my-windows@schneegans.github.com/"
cp metadata.json "$EXT_DIR/burn-my-windows@schneegans.github.com/"

# Limpiar y ajustar permisos
rm -rf /tmp/burn-my-windows
chmod -R 755 "$EXT_DIR"

echo "¡Extensiones instaladas! Versiones: Dash to Dock (v89), Just Perfection (v56), Lock Keys (v67), Burn My Windows (v47)"