#!/bin/bash

# Script para instalação automática do TigerVNC
# Autor: Raimundo Junior
# Data: 16/05/2025
# Baseado no tutorial do idroot: https://idroot.us/install-vnc-server-ubuntu-24-04/

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Por favor, execute este script como root ou usando sudo."
  exit 1
fi

# Atualiza os pacotes do sistema
echo "Atualizando os pacotes do sistema..."
apt update && apt upgrade -y

# Instala o ambiente de desktop XFCE e o TigerVNC
echo "Instalando o ambiente XFCE e o TigerVNC..."
apt install -y xfce4 xfce4-goodies tigervnc-standalone-server

# Solicita o nome de usuário para configurar o VNC
read -p "Digite o nome de usuário para configurar o VNC: " usuario

# Verifica se o usuário existe
if id "$usuario" &>/dev/null; then
  echo "Usuário encontrado: $usuario"
else
  echo "Usuário '$usuario' não encontrado. Criando o usuário..."
  adduser "$usuario"
fi

# Define a senha VNC para o usuário
echo "Configurando a senha VNC para o usuário $usuario..."
sudo -u "$usuario" vncpasswd

# Cria o diretório .vnc se não existir
sudo -u "$usuario" mkdir -p /home/"$usuario"/.vnc

# Cria o arquivo xstartup
echo "Criando o arquivo xstartup..."
cat <<EOF > /home/"$usuario"/.vnc/xstartup
#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
EOF

# Torna o xstartup executável
chmod +x /home/"$usuario"/.vnc/xstartup
chown "$usuario":"$usuario" /home/"$usuario"/.vnc/xstartup

# Cria o serviço systemd para o VNC
echo "Criando o serviço systemd para o VNC..."
cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Serviço VNC para o display %i
After=syslog.target network.target

[Service]
Type=forking
User=$usuario
Group=$usuario
WorkingDirectory=/home/$usuario

PIDFile=/home/$usuario/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :%i -geometry 1280x800 -depth 24
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

# Recarrega o systemd e habilita o serviço
echo "Recarregando o systemd e habilitando o serviço VNC..."
systemctl daemon-reload
systemctl enable vncserver@1.service
systemctl start vncserver@1.service

echo "Instalação e configuração do TigerVNC concluídas com sucesso!"
echo "Você pode se conectar ao VNC usando o IP do servidor e a porta 5901."
