# Affichage des droits des différents dossiers / fichiers présent dans un dossier

A la suite d'erreur de backup (car le Synology ne se connecte pas en root à la VM), il a été décidé de créer un script qui affiche les différents droits des dossiers/fichiers présent dans un dossier pour savoir les erreurs que l'on pourrait avoir sur des fichiers auquel on aurait pas accès sur l'utilisateur défini dans le Synology.

<ins>Voici le script en question</ins> [script_droits.sh](https://github.com/Grievous400/Projet-M1-TRI/blob/main/chirpstack/script_droits.sh)

Il s'utilise de la façon suivante :
```
./script_droits.sh /home/almalinux/thomas/chirpstack/ almalinux
```
Dans l'exemple suivant, le script vas regarder le dossier "/home/almalinux/thomas/chirpstack/" et afficher tout les dossiers / fichiers qui n'ont pas les droits appartenant à l'utilisateur "almalinux".

Voici la réponse du script :
![image](https://github.com/user-attachments/assets/8d9329b5-6735-4ab3-8ae7-e793e534188a)

La première réponse est l'**utilisateur propriétaire** puis le **groupe propriétaire**.
