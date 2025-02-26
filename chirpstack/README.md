# Mise en place d'un serveur ChirpStack

## Généralités

Clone modifié du repo [chirpstack-docker](https://github.com/chirpstack/chirpstack-docker).

## Modifications du repo

Changement des volumes **postgres** et **redis** en bind mount.

## Actions à faire

Les scripts ([Script_Backup_PostgresRedis](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_backup.sh), [Script_Backup_Influxdb](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_backup_influxdb.sh), [Script_Restore_PostgresRedis](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_restore.sh) et [Script_Restore_Influxdb](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_restore_influxdb.sh)) doivent être lancés en <ins>**sudo**</ins> et dans le dossier du docker compose.

Pour faciliter l'automatisation, [cron](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/cron.md) sera utiliser sur le serveur linux pour lancer le [script_backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_backup.sh).

L'installation d'[OpenVPN](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/vpn.md) sur le serveur Chirpstack.

Le paramétrage du Synology pour mettre en place le [VPN](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/synology_vpn.md) et [Active Backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/synology_activebackup.md).

(Optionnel : Le paramétrage de l'[Agent Linux Active Backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/synology_agentlinux.md) pour ajouter un Serveur Physique sous Linux)

(Optionnel : Le paramétrage pour créer une VM puis la restauration d'une backup d'un [Serveur Physique Active Backup avec le Recovery Media](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/synology_linuxrecovery.md).

## Problème connu

Depuis l'université, l'antivirus bloque l'affichage des 'Events' ou 'LoRaWan trames'.

Il faut donc penser a désactivé "l'analyse du trafic web" et "l'AMSI" (mise en OFF).
