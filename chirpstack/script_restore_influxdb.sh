#!/bin/bash

# Ajoute le chemin complet pour les commandes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Défini une variable pour le chemin d'acces a la sauvegarde
DEST_FOLDER="/var/backup_influxdb"

logger "Restore influxdb with ${DEST_FOLDER}"

# Copie des sauvegardes dans le dossier /root/influx_backup
/usr/bin/docker cp "${DEST_FOLDER}" iot-app-influxdb-1:/root/influx_backup

# Restaure et remplaces les données déjà existante avec --full
/usr/bin/docker exec iot-app-influxdb-1 influx restore /root/influx_backup --full
