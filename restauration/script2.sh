#!/bin/bash

# Variables
REMOTE_HOST="XXX.XXX.XXX.XXX"
REMOTE_USER="almalinux"
SSH_KEY_PATH="/home/etudiant/sshkeys/private_key_openssh"
DOCKER_USERNAME="projetm12425"
DOCKER_TOKEN="XXXXXXX"
BACKUP_REDISPOSTGRES="/var/backup"
BACKUP_INFLUX="/var/backup_influxdb"
SYNOLOGY_IP="10.8.0.6"

# Exécuter le script de configuration sur la machine distante
echo "---------------------------------------"
echo "Exécution du script de configuration."
echo "---------------------------------------"
ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST << EOF
echo "---------------------------------------"
echo "Test de la liaison avec le NAS Synology (via le VPN)."
echo "---------------------------------------"
ping -c 3 $SYNOLOGY_IP

echo "---------------------------------------"
echo "Installation de docker."
echo "---------------------------------------"
sudo dnf install -y dnf-utils
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
  
#echo "---------------------------------------"
#echo "Paramétrage de docker."
#echo "---------------------------------------"
#sudo usermod -aG docker almalinux
#echo "$DOCKER_TOKEN" | docker login --username $DOCKER_USERNAME --password-stdin
sudo docker run hello-world
sudo docker network create mon-reseau

echo "---------------------------------------"
echo "Paramétrage des dossiers pour les sauvegardes."
echo "---------------------------------------"
sudo mkdir $BACKUP_REDISPOSTGRES
sudo mkdir $BACKUP_INFLUX
sudo setfacl -R -m u:almalinux:rwx $BACKUP_REDISPOSTGRES
sudo setfacl -R -m u:almalinux:rwx $BACKUP_INFLUX
EOF
#echo "---------------------------------------"
#echo "Veuillez restaurer les sauvegardes depuis le NAS Synology et appuyer sur une touche une fois terminée."
#echo "---------------------------------------"
#sudo read -s -r
#ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST << EOF 
#sudo chmod +755 $BACKUP_REDISPOSTGRES
#sudo chmod +755 $BACKUP_INFLUX
#echo "---------------------------------------"
#echo "Note: Pensez à modifier (en cas de besoin) l'adresse IP de la Gateway LoraWan."
#echo "---------------------------------------"
#EOF
echo "---------------------------------------"
echo "Script terminé."
echo "---------------------------------------"
