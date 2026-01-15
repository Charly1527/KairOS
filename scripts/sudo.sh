#!/bin/bash
set -e

echo "==> Configurando sudo..."

echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
echo "==> Sudo configurado correctamente"

# echo -e "[User]\nSystemAccount=true" > /var/lib/AccountsService/users/zeus
