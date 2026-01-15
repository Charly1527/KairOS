#!/bin/bash
echo "==> Configurando el firewall UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable
