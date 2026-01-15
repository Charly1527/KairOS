#!/bin/bash
set -e

echo "==> Configurando usuarios de KairOS..."

# Grupo educativo
groupadd -f Mortales

# Usuario alumno
if ! id kairos &>/dev/null; then
  useradd -m -s /bin/bash -G Mortales,audio,video,input kairos
  echo "kairos:kairos" | chpasswd
fi

# Usuario administrador
if ! id hera &>/dev/null; then
  useradd -m -s /bin/bash -G wheel,audio,video,input,lp,lpadmin hera
  echo "hera:hera" | chpasswd
fi

# Superusuario
if ! id zeus &>/dev/null; then
  useradd -m -s /bin/bash -G wheel zeus
  echo "zeus:zeus" | chpasswd
fi

echo "==> Usuarios creados / verificados correctamente"
