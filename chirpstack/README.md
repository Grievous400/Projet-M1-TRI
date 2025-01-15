# Mise en place d'un serveur ChirpStack

## Généralités

Clone modifié du repo [chirpstack-docker](https://github.com/chirpstack/chirpstack-docker).

## Modifications du repo

Changement des volumes **postgres** et **redis** en bind mount.

## Actions à faire

Les scripts [script_backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_backup.sh) et [script_restore](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_restore.sh) doivent être lancés en <ins>**sudo**</ins> et dans le dossier du docker compose.

Pour faciliter l'automatisation, [cron](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/cron.md) sera utiliser sur le serveur linux pour lancer le [script_backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_backup.sh).

L'installation d'[OpenVPN](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/vpn.md) sur le serveur Chirpstack.

Le paramétrage du Synology pour mettre en place le [VPN](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/synology_vpn.md) et [Active Backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/synology_activebackup.md).


## Problème connu

Depuis l'université, l'antivirus bloque l'affichage des 'Events' ou 'LoRaWan trames'.

Il faut donc penser a désactivé "l'analyse du trafic web" et "l'AMSI" (mise en OFF).
