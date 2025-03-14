#!/bin/bash

# Variables
REMOTE_HOST="X.X.X.X"
REMOTE_USER="almalinux"
REMOTE_HOSTNAME="projet-m1-tri-24-25-2"
SSH_KEY_PATH="/home/etudiant/sshkeys/private_key_openssh"
OPENVPN_CONFIG_DIR="/home/etudiant/openvpn"
REMOTE_TEMP_DIR="/home/almalinux/openvpn_config"
REMOTE_OPENVPN_DIR="/etc/openvpn"
USERNAME_VPN="XXX"
PASSWORD_VPN="XXX"

# Créer le répertoire de destination sur la machine distante
echo "---------------------------------------"
echo "Création du répertoire $REMOTE_TEMP_DIR sur la machine distante."
echo "---------------------------------------"
ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST "mkdir -p $REMOTE_TEMP_DIR"

# Transférer les fichiers de configuration OpenVPN vers le répertoire temporaire
echo "---------------------------------------"
echo "Transfert des fichiers de configuration OpenVPN vers $REMOTE_TEMP_DIR."
echo "---------------------------------------"
scp -i $SSH_KEY_PATH -r $OPENVPN_CONFIG_DIR/* $REMOTE_USER@$REMOTE_HOST:$REMOTE_TEMP_DIR/

# Exécuter le script de configuration sur la machine distante
echo "---------------------------------------"
echo "Exécution du script de configuration."
echo "---------------------------------------"
ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST << EOF
#  echo "---------------------------------------"
#  echo "Mis à jour du système (en option)."
#  echo "---------------------------------------"
#  sudo dnf update -y
  
  echo "---------------------------------------"
  echo "Ajout d'un utilisateur."
  echo "---------------------------------------"
  sudo useradd -m $USERNAME_VPN
  echo "$USERNAME_VPN:$PASSWORD_VPN" | sudo chpasswd
  sudo id $USERNAME_VPN
  
  echo "---------------------------------------"
  echo "Changement du fuseau horaire."
  echo "---------------------------------------"
  sudo timedatectl set-timezone Europe/Paris

  echo "---------------------------------------"
  echo "Changement du hostname."
  echo "---------------------------------------"
  echo $REMOTE_HOSTNAME | sudo tee /etc/hostname
  sudo hostnamectl set-hostname $REMOTE_HOSTNAME

  echo "---------------------------------------"
  echo "Installation d'OpenVPN et firewalld."
  echo "---------------------------------------"
  sudo dnf install -y epel-release
  sudo dnf install -y openvpn firewalld
  sudo systemctl start firewalld
  sudo systemctl enable firewalld

  echo "---------------------------------------"
  echo "Copie des fichiers de configuration vers le répertoire OpenVPN."
  echo "---------------------------------------"
  sudo chmod 600 $REMOTE_TEMP_DIR/server/*
  sudo chmod 644 $REMOTE_TEMP_DIR/server/server.conf
  sudo cp -r $REMOTE_TEMP_DIR/* $REMOTE_OPENVPN_DIR/
  sudo chown root:openvpn $REMOTE_OPENVPN_DIR/server

  echo "---------------------------------------"
  echo "Configuration du firewall."
  echo "---------------------------------------"
  sudo firewall-cmd --permanent --new-zone=univ
  sudo firewall-cmd --permanent --zone=univ --add-source=193.48.120.0/20
  sudo firewall-cmd --permanent --zone=univ --add-source=193.48.128.0/21
  sudo firewall-cmd --permanent --zone=univ --add-port=1194/udp
  sudo firewall-cmd --permanent --zone=univ --add-port=22/tcp
  sudo firewall-cmd --reload

  echo "---------------------------------------"
  echo "Démarrage et activaction d'OpenVPN."
  echo "---------------------------------------"
  sudo systemctl start openvpn-server@server
  sudo systemctl enable openvpn-server@server
  sudo systemctl status openvpn-server@server
EOF
echo "---------------------------------------"
echo "Script terminé."
echo "---------------------------------------"
