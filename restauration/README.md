# Restauration complète d'un serveur ChirpStack ainsi que ses services

## 1er partie : Acquisition d'un VPS ou remise à zéro de celui-ci

Pour cette partie, nous devons avoir une machine VPS prête pour la suite de la procèdure. Pour cela, nous utilisons l'entreprise OVH pour avoir accès à des VPS prêt à l'emploi.

![image](https://github.com/user-attachments/assets/56d58b6f-48e4-4278-b169-04da5fa4824e)

Il suffit dans notre exemple, de cliquer sur <ins>Réinstaller mon VPS</ins>

![image](https://github.com/user-attachments/assets/ed3e2571-2826-4eb7-9988-d188c5f17780)

Puis de choisir <ins>AlmaLinux9</ins> et d'inserer la <ins>clé SSH publique</ins> créée pour l'occasion.

Ensuite, une fois la machine remise à zéro, nous pouvons par la suite utiliser les différents scripts.

## 2ème partie : Script pour la préparation serveur + mise en place d'une liaison OpenVPN

Pour cette partie, nous devons utiliser un script qui permet de préparer la machine VPS pour qu'elle puisse ensuite être utilisé pour les autres parties.

[Script n°1](https://github.com/Grievous400/Projet-M1-TRI/blob/main/restauration/script1.sh)

Le script permet de charger la configuration d'OpenVPN, puis d'installer/configurer le firewall, OpenVPN et de faire en sorte que la liaison VPN soit prête à recevoir la connexion du NAS Synology.

Pour pouvoir utiliser ce script, il faut déjà pré-remplir les différentes variables accessibles au début du script en fonction de nos données (**adresse IP**, **nom d'utilisateur** ainsi que son **mot de passe**).

Les fichiers nécessaires pour OpenVPN sont : **ca.crt**, **dm.pem**, **server.conf**, **server.crt**, **server.key**, **ta.key**.

### 3ème partie : Script pour la mise en place de docker ainsi que des différents docker composes


### 4ème partie : Restauration des base de données des différents services (Redis, PostGres & InfluxDB)

