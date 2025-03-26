# Configuration de Mosquitto avec TLS via Traefik et Let's Encrypt

## Préparation des certificats

Dans cette partie, nous allons voir comment mettre en place le TLS pour Mosquitto en utilisant les certificats Let's Encrypt de notre Traefik. Il est également nécessaire d'avoir le certificat d'autorité (CA) de Let's Encrypt, que l'on peut récupérer sur le site de [Let's Encrypt](https://letsencrypt.org/fr/certificates/).

---

## Extraction des certificats depuis Traefik

Placez-vous dans le même dossier que le fichier `acme.json` de Traefik, qui contient les certificats.  
Utilisez la commande suivante pour extraire les certificats :

```bash
sudo traefik-certs-dumper file \
  --source acme.json \
  --dest /pem \
  --version v3 \
  --domain-subdir \
  --crt-ext=.pem \
  --key-ext=.pem
```

Cette commande va créer un dossier `pem` contenant :

- Un sous-dossier par domaine et sous-domaine.
- Un dossier avec la clé privée.

Dans notre cas, nous allons nous intéresser au sous-dossier `preprod2.univ-lorawan.fr`.  
Ce dossier contiendra :

- Le certificat du domaine (`certificate.pem`)  
- La clé privée (`privatekey.pem`)  
- Le certificat d'autorité (CA) (`cafile.pem`)  

---

## Copie des certificats dans le dossier de configuration de Mosquitto

```bash
cp /pem/preprod2.univ-lorawan.fr/certificate.pem iot-app/mosquitto-client/config/certs/
cp /pem/preprod2.univ-lorawan.fr/privatekey.pem iot-app/mosquitto-client/config/certs/
cp /pem/preprod2.univ-lorawan.fr/cafile.pem iot-app/mosquitto-client/config/certs/
```

---

## Configuration de Mosquitto

Rendez-vous dans le fichier `iot-app/mosquitto-client/config/mosquitto.conf` et ajoutez la configuration suivante :

```conf
# MQTTS Listener 8883
listener 8883 0.0.0.0
#allow_anonymous true
password_file /mosquitto/config/passdb
acl_file /mosquitto/config/authorization.acl
#log_type all

connection Clients
address mosquitto:1883
remote_password ""
remote_username ""
topic application/# both 0

certfile /mosquitto/config/certs/certificate.pem
keyfile /mosquitto/config/certs/privatekey.pem
cafile /mosquitto/config/certs/cafile.pem
```

---

## Ouverture du port sur Docker

N'oubliez pas d'ouvrir le port 8883 dans votre configuration Docker Compose :

```yaml
services:
  mosquitto:
    ports:
      - "8883:8883"
```

---

## Configuration des utilisateurs dans Mosquitto

Pour définir un utilisateur et un mot de passe dans Mosquitto, utilisez la commande suivante :

```bash
mosquitto_passwd /mosquitto/config/passdb <username>
```

---

## Gestion des droits utilisateurs

Les droits des utilisateurs sont gérés dans le fichier suivant :

```
iot-app/mosquitto-client/config/authorization.acl
```

---

## Test de la configuration

Après avoir suivi ces étapes, votre Mosquitto devrait être accessible uniquement via MQTT TLS.  
Pour tester la configuration, vous pouvez utiliser **MQTTBox** afin de simuler un client se connectant au serveur.

![image](https://github.com/user-attachments/assets/7b346267-fee7-4e06-b2e5-c36e078730f7)

