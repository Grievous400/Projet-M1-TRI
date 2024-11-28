## Historique

### *28/11/2024*
Installation du docker compose Chirpstack.

Configuration de la Gateway LoRaWan sur le serveur.

Configuration des 2 capteurs de températures LHT65 sur le serveur.

Problème d'affichages des 'Event' et 'LoRaWan Frames' sur le site web depuis l'université. Il faut mettre sur l'antivirus F-Secure Client l'analyse du trafic web & AMSI en OFF.

### *27/11/2024*
Approfondissement du cours LoRaWan.

Récupération des 2 sondes de températures LHT65.

Apprentissage sur le fonctionnement de celles-ci.

Mail envoyé au professeur pour savoir l'adresse IP de la Gateway LoRaWan

### *21/11/2024*
Commencement du cours sur le LoRaWaN et modifications des dockers compose.

Ajout des versions http et https pour pouvoir utiliser le site sur port 80 et 443 si besoin.

Modification du github avec l'ajout d'un dossier wordpress_univ pour mettre les dockers compose dedans.

Modification des dockers compose avec l'ajout d'un fichier de variable d'environnement .env pour éviter que les mots de passe ne soit divulgés sur le github.

### *20/11/2024*
Essais avec différentes versions de Wordpress (version 5.8.3 puis 5.8 et 5.4). Toujours en erreur concernant un module PHP et le plugin fusion-builder.

Pour éviter l'importation de fichiers non compatibles, j'importe complètement le site internet (pas uniquement wp-content) mais cela n'y change rien.

L'erreur indique une version de class-phpmailer.php utilisé qui serait dépréciée depuis la version Wordpress 5.5.0 (hors le site fonctionne avec une version 5.8.6 de WP).

Mail envoyé au professeur pour expliquer le problème. Bascule sur l'apprentissage du Lorawan.

### *15/11/2024*
Mail envoyé au professeur pour savoir les versions utilisées car j'ai une erreur PHP avec la dernière version de Wordpress (PHP v8).

Utilisation du code fourni par Louis pour avoir un certificat généré par LetsEncrypt.

Réponse du professeur, version utilisé sur le serveur web (WP : 5.8.6 / PHP : 7.4.33).

Problème est qu'il n'existe pas d'image Wordpress concernant la version 5.8.6.

On retrouve les images WordPress avec comme version 5.8.3 puis 5.9. J'utiliserai donc la 5.8.3 (PHPv5.4.27) qui se rapproche le plus du cas d'utilisation du serveur (PHPv5.4.33).

### *14/11/2024*
Pendant l'investigation sur les erreurs en cours, j'en apprends plus sur Docker, Wordpress et la base de données.

Dans le cas d'un conteneur, on peut <ins>uniquement</ins> utiliser les fichiers ci-dessous pour la sauvegarde :
```
/wp-content/
   /plugins/         <- Plugins installés
   /themes/          <- Thèmes installés
   /uploads/         <- Médias
/.htaccess           <- Règles spécifiques
/robots.txt          <- Fichier pour les moteurs de recherche
/wp-config.php       <- Configuration personnalisée
```
L'entrypoint du Docker Wordpress regardera ainsi dans le volume et installera <ins>uniquement</ins> les fichiers manquant.

Cela permet un gain de place et évite d'importer toute la configuration du site web.

### *8/11/2024*
Le site fonctionne mais je comprends vite que cela ne fonctionne pas (l'URL rebascule sur l'ancien site).

En cherchant dans la base de données, je trouve qu'il existe une multitude de références à l'ancienne URL qui vas falloir changer pour le nouveau nom de domaine (wp_options, wp_postmeta, wp_posts et wp_yoast)

Modification des liens dans la base de données vers le nouveau nom de domaine.

A la suite de cela, j'ai des erreurs concernant un plugin fusion-builder (liens avec le thème Avada) qui ne fonctionne pas avec la dernière version de Wordpress (et donc PHP).

### *7/11/2024*
Renseignement sur la méthode de chiffrement du mot de passe par Wordpress dans la base de données. 

D'après des recherches, Wordpress n'utilise plus MD5 mais une méthode plus complexe pour inscrire le mot de passe dans la base de données. Du coup, pour l'instant, le mot de passe sera remplacé par ' ' dans un but de test.

Renseignement sur *user_activationkey* qui sert uniquement dans le cas d'un oubli de mot de passe. 

Wordpress génère une clé qui vas insérer à cet emplacement et l'envoyer aussi par mail. Quand l'utilisateur cliquera sur le lien, Wordpress comparera si les deux clés sont les mêmes pour valider (ou non) que c'est bien le bon utilisateur.

Modification sur le *wp-config.php* des différents informations nécessaires.

Modification dans la base de données des informations sur le *wp_users*.

Découvert dans l'entrypoint du conteneur mysql qu'on peut fixer un dump pour qu'il l'importe automatique au démarrage (./backup.sql:/docker-entrypoint-initdb.d/dump.sql:ro)