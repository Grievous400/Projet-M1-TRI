# Mise en place d'un serveur ChirpStack

## Généralités

Clone modifié du repo [chirpstack-docker](https://github.com/chirpstack/chirpstack-docker).

## Modifications du repo

Changement des volumes **postgres** et **redis** en bind mount.

## Actions à faire

Les scripts [script_backup](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_backup.sh) et [script_restore](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_restore.sh) doivent être lancés en <ins>**sudo**</ins> et dans le dossier du docker compose.

## Installation d'OpenVPN sur le Serveur
<ins>Installation des services</ins>
```
yum update
yum install openvpn easy-rsa
```

<ins>Initialisation de la PKI</ins>
```
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
```

Modifier les valeurs présentes (CN, O, OU..) dans le fichier "<ins>vars</ins>" pour la génération du certificat de la CA

<ins>Installation de la CA et génération de la clé/certificat pour le server ChirpStack</ins>
```
./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa gen-req server nopass
./easyrsa sign-req server server
```

<ins>Copie des fichiers générés dans le dossier server d'OpenVPN</ins>
```
cp /etc/openvpn/easy-rsa/pki/issued/server.crt /etc/openvpn/server
cp /etc/openvpn/easy-rsa/pki/private/server.key /etc/openvpn/server
cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/server
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/server
```

<ins>Ouverture du port pour la mise en place du VPN ainsi que l'activation du routage IPv4</ins>
```
firewall-cmd --add-port=1194/udp --permanent
firewall-cmd --permanent --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-interface=tun0
firewall-cmd --reload
sysctl -w net.ipv4.ip_forward=1
sysctl -p
```

<ins>Copie et modification de la configuration du serveur OpenVPN</ins>
```
cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn/server
cd /etc/openvpn/server
nano server.conf
```

Modifier la valeur dh en <ins>dh.pem</ins>

<ins>Activation du Serveur OpenVPN et paramétrage pour qu'il se lance au démarrage du serveur</ins>
```
systemctl start openvpn-server@server
systemctl enable openvpn-server@server
```

<ins>Génération du certificat pour le client</ins>
```
cd /etc/openvpn/easy-rsa
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1
```

<ins>Copie de la configuration client et paramétrage pour notre utilisation</ins>
```
cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf /etc/openvpn/client/client.ovpn
cd /etc/openvpn/client
nano client.ovpn
```

Modifier la valeur de <ins>l'adresse ip</ins> ou le <ins>nom de domaine</ins> et supprimer la ligne <ins>ta.key</ins>

<ins>Copie les fichiers nécessaire au fichier .opvn pour le client</ins>
```
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client
cp /etc/openvpn/easy-rsa/pki/issued/client1.crt /etc/openvpn/client
cp /etc/openvpn/easy-rsa/pki/private/client1.key /etc/openvpn/client
```

Modifier le <ins>client.opvn</ins> et insérer à la fin les différents fichiers dans leur emplacements respectifs :
```
<ca>
-----BEGIN CERTIFICATE-----
# Contenu du fichier ca.crt
-----END CERTIFICATE-----
</ca>

<cert>
-----BEGIN CERTIFICATE-----
# Contenu du fichier client.crt
-----END CERTIFICATE-----
</cert>

<key>
-----BEGIN PRIVATE KEY-----
# Contenu du fichier client.key
-----END PRIVATE KEY-----
</key>

#<tls-auth>
#-----BEGIN OpenVPN Static key V1-----
# Contenu du fichier ta.key (pas utilisé)
#-----END OpenVPN Static key V1-----
#</tls-auth>
```

## Problème connu

Depuis l'université, l'antivirus bloque l'affichage des 'Events' ou 'LoRaWan trames'.

Il faut donc penser a désactivé "l'analyse du trafic web" et "l'AMSI" (mise en OFF).
