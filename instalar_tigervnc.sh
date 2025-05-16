#!/bin/bash

# Script para instalação automática do TigerVNC
# Autor: Raimundo Junior
# Data: 16/05/2025

# Função para verificar se o usuário é root
verificar_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root (sudo)."
    exit 1
  fi
}

# Função para instalar em sistemas Debian/Ubuntu
instalar_debian() {
  echo "Atualizando pacotes..."
  apt update -y && apt upgrade -y

  echo "Instalando TigerVNC..."
  apt install -y tigervnc-standalone-server tigervnc-common

  echo "TigerVNC instalado com sucesso no Debian/Ubuntu!"
}

# Função para instalar em sistemas Red Hat/CentOS
instalar_redhat() {
  echo "Atualizando pacotes..."
  yum update -y

  echo "Instalando TigerVNC..."
  yum install -y tigervnc-server

  echo "TigerVNC instalado com sucesso no RHEL/CentOS!"
}

# Função principal
main() {
  verificar_root

  echo "Detectando o sistema operacional..."
  if [ -f /etc/debian_version ]; then
    instalar_debian
  elif [ -f /etc/redhat-release ]; then
    instalar_redhat
  else
    echo "Sistema operacional não suportado por este script."
    exit 1
  fi

  echo ""
  echo "Para iniciar o VNC Server, execute: vncserver"
  echo "Para configurar uma senha, execute: vncpasswd"
}

# Executa a função principal
main
