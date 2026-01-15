#!/bin/bash
set -e

bash scripts/packages.sh
bash scripts/users.sh
bash scripts/sudo.sh
bash scripts/services.sh
bash scripts/wallpapers.sh
bash scripts/gdm-theme.sh
bash scripts/dconf.sh
bash scripts/extensions.sh
bash scripts/os-release.sh
