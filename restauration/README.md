# Restauration complète d'un serveur ChirpStack ainsi que ses services

## 1er partie : Acquisition d'un VPS ou remise à zéro de celui-ci

Pour cette partie, nous devons avoir une machine VPS prête pour la suite de la procèdure. Pour cela, nous utilisons l'entreprise OVH pour avoir accès à des VPS prêt à l'emploi.

![image](https://github.com/user-attachments/assets/56d58b6f-48e4-4278-b169-04da5fa4824e)

Il suffit dans notre exemple, de cliquer sur <ins>Réinstaller mon VPS</ins>

![image](https://github.com/user-attachments/assets/ed3e2571-2826-4eb7-9988-d188c5f17780)

Puis de choisir <ins>AlmaLinux9</ins> et d'inserer la <ins>clé SSH publique</ins> créée pour l'occasion.

Ensuite, une fois la machine remise à zéro, nous pouvons par la suite utiliser les différents scripts.

Enfin, il faut penser à changer l'adresse IP du nom de domaine utilisé par nos VPS (soit directement sur le site d'OVH ou sinon par le biais d'un script DDNS).

## 2ème partie : Script pour la préparation serveur + mise en place d'une liaison OpenVPN

Pour cette partie, nous utiliserons un script qui permet de préparer la machine VPS pour qu'elle puisse ensuite être utilisé par la suite.

[Script n°1](https://github.com/Grievous400/Projet-M1-TRI/blob/main/restauration/script1.sh)

Le script permet de :
* Chargement la configuration d'OpenVPN.
* Création d'un utilisateur utilisé pour la connexion VPN.
* Changement du hostname.
* Désactivation de l'IPv6 (du à un problème avec docker hub).
* Installation / configuration le firewall.
* Installation / configuration OpenVPN.

Pour pouvoir utiliser ce script, il faut déjà pré-remplir les différentes variables accessibles au début du script en fonction de nos données (**adresse IP**, **nom d'utilisateur** ainsi que son **mot de passe**).

Les fichiers nécessaires pour OpenVPN sont : **ca.crt**, **dm.pem**, **server.conf**, **server.crt**, **server.key**, **ta.key**.

## 3ème partie : Script pour la mise en place de docker ainsi que des différents fichiers qui sont liées à celui-ci

Ensuite, dans cette partie, nous utiliserons un script pour préparer la machine VPS sur le plan docker et sauvegardes.

[Script n°2](https://github.com/Grievous400/Projet-M1-TRI/blob/main/restauration/script2.sh)

Avant de lancer le script, il faut vérifier sur le Synology que nous sommes bien connecté sur le VPN du VPS.

Le script permet de :
* Tester la liaison VPN avec le Synology.
* Installation / configuration de docker.
* Paramétrage des dossiers pour la sauvegarde.

Ensuite une fois le script fini, il faut retourner sur le **Synology Active Backup** et permettre la restauration des différentes sauvegardes effectuées au préalable.

## 4ème partie : Script pour modifier les droits des fichiers vitaux au docker compose

Dans cette partie, nous utiliserons un script pour adapter les bons droits aux bons fichiers car certains ont besoin de droits spéciaux pour pouvoir être executer. C'est le cas des fichiers de mosquitto (1883) par exemple.

Lors qu'ils sont copiées par Synology (Active Backup), l'utilisateur et le groupe deviennent ceux de l'utilisateur utilisé pour se connecter au VPS (dans notre cas : *almalinux*)

[Script n°3](https://github.com/Grievous400/Projet-M1-TRI/blob/main/restauration/script3.sh)

Le script permet de :
* Adapter les droits aux bons fichiers.

## 5ème partie : Restauration des base de données des différents services (Redis, PostGres & InfluxDB)

Enfin, une fois tous les fichiers restaurés et installés, il faut lancer les script permettant de restaurer les sauvegardes.

Pour cela, nous allons utiliser deux scripts. L'un pour Redis&Postgres, l'autre pour InfluxDB.

```
sudo /home/almalinux/thomas/chirpstack/script_restore.sh
```

Puis, une fois la restauration terminée, on peut lancer le docker compose dans le dossier chirpstack qui contient les services suivant :
* Chirpstack
* Mosquitto
* Postgres
* Redis
* Traefik

```
cd /home/almalinux/thomas/chirpstack/
docker compose up -d
```

Puis pour la deuxième partie, il faut lancer déjà le docker compose dans le dossier iot-app qui content les services suivant :

* InfluxDB
* Grafana
* Mosquitto
* Telegraf

```
cd /home/almalinux/florent/iot-app/
docker compose up -d
```

Puis une fois docker compose démarré, un faut lancer le script de restauration.

```
sudo /home/almalinux/florent/iot-app/script_restore_influxdb.sh
```

Et voilà, les différents services ont pu être restaurés et remis comme à l'état au moment de la sauvegarde.
