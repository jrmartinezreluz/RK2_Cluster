#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root o con sudo."
  exit 1
fi

if [ "$1" != "server" ] && [ "$1" != "agent" ]; then
  echo "Uso: $0 server|agent"
  exit 1
fi

echo "Instalando RKE2 como $1..."

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=$1 sh -

if [ "$1" == "server" ]; then
  systemctl enable rke2-server.service
  systemctl start rke2-server.service
else
  systemctl enable rke2-agent.service
  systemctl start rke2-agent.service
fi

echo "✅ RKE2 $1 instalado correctamente"
