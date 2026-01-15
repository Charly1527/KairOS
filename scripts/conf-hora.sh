#!/bin/bash
echo "==> Configurando la sincronización de hora..."
timedatectl set-ntp true
timedatectl set-timezone America/Mexico_City
echo "==> Sincronización de hora configurada correctamente"

echo "==> Cups: Agregando usuarios a grupos de impresión..."
usermod -aG lp Kairos
usermod -aG lpadmin Hera
echo "==> Cups: Usuarios agregados a grupos correctamente"  
