#!/bin/bash
set -e

echo "==> Configurando sudo..."

cat <<EOF > /etc/sudoers.d/kairos
%wheel ALL=(ALL) ALL
EOF

chmod 440 /etc/sudoers.d/kairos

echo -e "[User]\nSystemAccount=true" > /var/lib/AccountsService/users/zeus
