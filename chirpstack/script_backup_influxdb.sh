#!/bin/bash

# Ajoute le chemin complet pour les commandes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Défini une variable pour le chemin d'acces au serveur
SERVER_DIR="/home/almalinux/florent/iot-app"

# Défini une variable pour le chemin d'acces a la sauvegarde
DEST_FOLDER="/var/backup_influxdb"
logger "Backup influxdb to ${DEST_FOLDER}"

# Définition du token utiliser pour permettre la sauvegarde
token="uk8yS3KzVkhaF0cf/CFWy044i8qpNTenEKGCA3SgWK8="

# Supprime l'ancienne sauvegarde
rm -rf "${DEST_FOLDER}"

# Changement de dossier pour celui du docker compose afin d'executer la commande docker
cd "$SERVER_DIR" || exit 1

# Effectue la nouvelle sauvegarde
/usr/bin/docker exec iot-app-influxdb-1 sh -c 'rm -rf /root/influx_backup'
/usr/bin/docker exec iot-app-influxdb-1 influx backup /root/influx_backup -t "${token}"

# Copie les sauvegardes dans le dossier DEST_FOLDER
sudo docker cp iot-app-influxdb-1:/root/influx_backup "${DEST_FOLDER}"
sudo chown -R almalinux "${DEST_FOLDER}"
echo "Fichiers influxdb copiés dans le dossier actuel."
