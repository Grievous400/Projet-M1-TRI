#!/bin/bash

# Ajoute le chemin complet pour les commandes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Défini une variable pour le chemin d'acces au serveur
SERVER_DIR="/home/almalinux/thomas/chirpstack"

# Défini une variable pour le chemin d'acces a la sauvegarde
SAVE_DIR="/var/backup"

# Vérifie si le dossier "sauvegardes" existe
if [ ! -d "$SAVE_DIR" ]; then
    # Si le dossier n'existe pas, le créer
    mkdir "$SAVE_DIR"
    echo "Le dossier 'sauvegardes' a été créé."
else
    # Si le dossier existe déjà, ne rien faire
    echo "Le dossier 'sauvegardes' existe déjà."
fi

# Copie le fichier dump.rdb de Redis
if [ -f "$SERVER_DIR/redisdata/dump.rdb" ]; then
    cp "$SERVER_DIR/redisdata/dump.rdb" "$SAVE_DIR"
    echo "Fichier dump.rdb copié dans le dossier actuel."
    # Permet au Synology de copier le fichier (par défaut : 600 root)
    chmod 644 "$SAVE_DIR/dump.rdb"
    logger "Backup BDD Redis to ${SAVE_DIR}"
else
    echo "Erreur : Le fichier dump.rdb n'existe pas."
    exit 1
fi

# Changement de dossier pour celui du docker compose afin d'executer la commande docker
cd "$SERVER_DIR" || exit 1

# Récupération de la base de données Postgres vers dump.sql
/usr/bin/docker exec chirpstack-postgres-1 pg_dumpall -c --no-password -h localhost -U postgres > "$SAVE_DIR/dump.sql"

# Vérification du code de retour de la commande docker
if [ $? -eq 0 ]; then
    echo "Fichier dump.sql copié dans le dossier actuel."
    logger "Backup BDD Postgres to ${SAVE_DIR}"
else
    echo "Erreur : le fichier dump.sql n'a pas pu être extrait."
    exit 1
fi
