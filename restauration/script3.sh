#!/bin/bash

REMOTE_HOST="XXX.XXX.XXX.XXX"
REMOTE_USER="almalinux"
SSH_KEY_PATH="/home/etudiant/sshkeys/private_key_openssh"

# Exécuter le script de configuration sur la machine distante
echo "---------------------------------------"
echo "Exécution du script de configuration."
echo "---------------------------------------"
ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST << 'EOF'
declare -A permissions=(
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/mosquitto.conf"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/authorization.acl"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/passdb"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/certs"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/certs/cafile.pem"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/certs/certificate.pem"]="1883|1883"
    ["/home/almalinux/florent/iot-app/mosquitto-clients/config/certs/privatekey.pem"]="1883|1883"
    ["/home/almalinux/florent/iot-app/grafana/data/plugins"]="472|root"
    ["/home/almalinux/florent/iot-app/grafana/data/grafana.db"]="472|root"
    ["/home/almalinux/florent/iot-app/grafana/data/png"]="472|root"
    ["/home/almalinux/florent/iot-app/grafana/data/csv"]="472|root"
    ["/home/almalinux/florent/iot-app/grafana/data/pdf"]="472|root"
    ["/home/almalinux/thomas/chirpstack/configuration/mosquitto"]="root|root"
    ["/home/almalinux/thomas/chirpstack/configuration/mosquitto/config"]="1883|1883"
    ["/home/almalinux/thomas/chirpstack/configuration/mosquitto/config/mosquitto.conf"]="1883|1883"
)

for path in "${!permissions[@]}"; do
    if [ -e "$path" ]; then
        owner_group=${permissions[$path]}
        owner=$(echo "$owner_group" | cut -d'|' -f1)
        group=$(echo "$owner_group" | cut -d'|' -f2)
        echo "Modification de $path - Propriétaire: $owner, Groupe: $group"
        sudo chown "$owner:$group" "$path"
    else
        echo "Avertissement: $path n'existe pas."
    fi
done

sudo setfacl -R -m u:almalinux:rx /home/almalinux/thomas/*
sudo setfacl -R -m u:almalinux:rx /home/almalinux/florent/*
sudo chmod 600 /home/almalinux/thomas/chirpstack/letsencrypt/acme.json

EOF
echo "---------------------------------------"
echo "Script terminé."
echo "---------------------------------------"
