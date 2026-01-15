#!/bin/bash
set -e

echo "==> Aplicando configuración dconf de KairOS..."

mkdir -p /etc/dconf/db/local.d
mkdir -p /etc/dconf/db/local.d/locks

cp /root/KairOS/branding/dconf/*.ini /etc/dconf/db/local.d/
cp /root/KairOS/branding/dconf/locks/* /etc/dconf/db/local.d/locks/

dconf update
