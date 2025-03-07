# Installation d'OpenVPN sur le Serveur

<ins>(Optionnel) Mise à l'heure du serveur</ins>
```
timedatectl set-timezone Europe/Paris
```

<ins>Installation des services (OpenVPN dispo sur les dépôts EPEL)</ins>
```
dnf update
dnf install epel-release
dnf install openvpn easy-rsa
```

<ins>Initialisation de la PKI</ins>
```
mkdir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
```
*Modifier les valeurs présentes (CN, O, OU..) dans le fichier "<ins>vars</ins>" pour la génération du certificat de la CA*

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

<ins>Ouverture de ports sur le firewall pour la mise en place du VPN</ins>
```
firewall-cmd --permanent --new-zone=univ
firewall-cmd --permanent --zone=univ --add-source=193.48.120.0/20
firewall-cmd --permanent --zone=univ --add-source=193.48.128.0/21
firewall-cmd --permanent --zone=univ --add-port=1194/udp
firewall-cmd --permanent --zone=univ --add-port=22/tcp
firewall-cmd --reload
```

<ins>Copie et modification de la configuration du serveur OpenVPN</ins>
```
cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn/server
cd /etc/openvpn/server
nano server.conf
```
*Modifier la valeur dh en <ins>dh.pem</ins>*

<ins>Ajout de la clé ta.key pour le TLS Auth</ins>
```
openvpn --genkey tls-auth ta.key
```

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
*Modifier la valeur de <ins>l'adresse ip</ins> ou le <ins>nom de domaine</ins> (ligne 'remote')</ins>*

<ins>Copie les fichiers nécessaire au fichier .opvn pour le client</ins>
```
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client
cp /etc/openvpn/easy-rsa/pki/issued/client1.crt /etc/openvpn/client
cp /etc/openvpn/easy-rsa/pki/private/client1.key /etc/openvpn/client
cp /etc/openvpn/server/ta.key /etc/openvpn/client
```

<ins>Modifier le <ins>client.opvn</ins> et insérer à la fin les différents fichiers dans leur emplacements respectifs</ins>
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

<tls-auth>
-----BEGIN OpenVPN Static key V1-----
# Contenu du fichier ta.key
-----END OpenVPN Static key V1-----
</tls-auth>
```
