#!/bin/bash

# Vérifie que le nombre d'arguments est correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <répertoire> <nom_utilisateur>"
    exit 1
fi

DIRECTORY=$1
USERNAME=$2

# Vérifie si le répertoire existe
if [ ! -d "$DIRECTORY" ]; then
    echo "Le répertoire $DIRECTORY n'existe pas."
    exit 1
fi

# Parcourt le répertoire et affiche les fichiers/dossiers avec un propriétaire différent
find "$DIRECTORY" | while read -r file_path; do
    owner_and_group=$(ls -ld "$file_path" | awk '{print $3 " | " $4}')
    owner=$(echo "$owner_and_group" | cut -d'|' -f1 | xargs)
    if [ "$owner" != "$USERNAME" ]; then
        if [ -d "$file_path" ]; then
            type="Dossier"
        else
            type="Fichier"
        fi
        echo "$type: $file_path - $owner_and_group"
    fi
done
