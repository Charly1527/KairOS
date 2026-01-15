#!/bin/bash
set -e

echo "==> Configurando usuarios de KairOS..."

# Función segura para grupos
ensure_group() {
  getent group "$1" >/dev/null || groupadd "$1"
}

# Grupos necesarios
for g in mortales wheel audio video input storage lp lpadmin; do
  ensure_group "$g"
done

create_user() {
  local user=$1
  local groups=$2
  local pass=$3

  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash -G "$groups" "$user"
    echo "$user:$pass" | chpasswd
  fi
}

create_user kairos "mortales,audio,video,input,storage" kairos
create_user hera   "wheel,audio,video,input,lp,lpadmin,storage" hera
create_user zeus   "wheel,audio,video,input,storage" zeus

echo "==> Usuarios creados correctamente"
