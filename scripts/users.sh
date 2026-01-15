#!/bin/bash
set -e

echo "==> Configurando usuarios de KairOS..."

groupadd -f mortales

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
