# Paramétrage de cron

Afin d'automatiser les sauvegardes, nous allons utiliser cron sur le serveur linux.

Tout d'abord, nous allons passer en root (vu que le script doit être lancé en sudo), lancer cron et faire en sorte qu'il se lance aussi au démarrage du serveur.

```
sudo -i
systemctl start crond
systemctl enable crond
crontab -e
```

Enfin, sous cron, rajouter la ligne suivante et quitter. Elle permet de lancer le script de backup toutes les 15 minutes.
```
*/15 * * * * /home/almalinux/thomas/chirpstack/script_backup.sh
*/15 * * * * /home/almalinux/florent/iot-app/script_backup_influxdb.sh
```

Pour être certain que la commande a bien été prise en compte, on peut se servir de la commande suivante pour voir les tâches paramétrer.
```
crontab -l
```
