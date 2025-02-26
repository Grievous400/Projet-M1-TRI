#!/bin/bash
dest_folder="/var/backup_influxdb"
logger "Restore influxdb with ${dest_folder}"

# Copie des sauvegardes dans le dossier /root/influx_backup
sudo docker cp "${dest_folder}" iot-app-influxdb-1:/root/influx_backup

# Restaure et remplaces les données déjà existante avec --full
sudo docker exec iot-app-influxdb-1 influx restore /root/influx_backup --full
