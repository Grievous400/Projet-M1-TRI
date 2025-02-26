#!/bin/bash

# Défini une variable pour le chemin d'acces au serveur
SERVER_DIR="/home/almalinux/thomas/chirpstack"

# Défini une variable pour le chemin d'acces a la sauvegarde
SAVE_DIR="/var/backup"

# Crée les répertoires redisdata et postgresqldata
mkdir -p "$SERVER_DIR/redisdata" "$SERVER_DIR/postgresqldata"

# Copie le fichier dump.rdb (Redis) dans son répertoire
if [ -f "$SAVE_DIR/dump.rdb" ]; then
    cp "$SAVE_DIR/dump.rdb" "$SERVER_DIR/redisdata"
    echo "Fichier dump.rdb copié dans le dossier redisdata."
    logger "Backup BDD ${SAVE_DIR} to Redis"
else
    echo "Erreur : Le fichier dump.rdb n'existe pas."
    exit 1
fi

# Vérification de la présence du fichier dump.sql (PostgreSQL)
if [ -f "$SAVE_DIR/dump.sql" ]; then
    # Changement de dossier pour celui du docker compose afin d'executer la commande docker
    cd "$SERVER_DIR" || exit 1
    # Lance le Docker Compose uniquement pour le service postgres
    docker compose up postgres -d --wait
    sleep 5
    # Restaure la base de données PostgreSQL depuis le dump.sql
    docker compose exec -T postgres psql -h localhost -U postgres < "$SAVE_DIR/dump.sql"
    # Arrête le Docker Compose
    docker compose down
    # Relance le Docker Compose avec tout les services
    docker compose up -d
    logger "Backup BDD ${SAVE_DIR} to Postgres"
else
    echo "Erreur : Le fichier dump.sql n'existe pas."
    exit 1
fi
