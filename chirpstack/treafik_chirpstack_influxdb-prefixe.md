# Problème de redirection des assets avec Traefik et ChirpStack

## Contexte

Nous avons mis en place un serveur **ChirpStack** exposé via **Traefik** en tant que reverse proxy. L'application est hébergée sur un VPS et est accessible via l'URL :

```
https://preprod2.univ-lorawan.fr/chirpstack/
```

L'application fonctionne correctement **lorsqu'elle est accédée directement** via son port (ex: `http://vps-2bda0e50.vps.ovh.net:8080/`). Cependant, lors de l'accès via Traefik, les fichiers statiques (`CSS`, `JS`, `PNG`) ne sont pas chargés correctement.

---

## Technologies utilisées

- **ChirpStack** : serveur LoRaWAN permettant de gérer des appareils IoT.
- **Traefik** : reverse proxy utilisé pour gérer l'accès aux services avec HTTPS.
- **Docker & Docker Compose** : orchestration des services.

---

## Problème rencontré

### 1. **Les assets ne se chargent pas via Traefik**
Lors de l'accès via `https://preprod2.univ-lorawan.fr/chirpstack/`, la page s'affiche mais les fichiers CSS et JS renvoient une **erreur 404**.

####  **Analyse des logs de Traefik :**

```
193.48.121.87 - - [13/Feb/2025:11:08:08 +0000] "GET /assets/index-B204SH-X.js HTTP/2.0" 404 19 "-" "-" 2 "-" "-" 0ms
193.48.121.87 - - [13/Feb/2025:11:08:08 +0000] "GET /assets/index-C-P4JNPO.css HTTP/2.0" 404 19 "-" "-" 3 "-" "-" 0ms
```

Les requêtes pour les assets sont envoyées à `/assets/` au lieu de `/chirpstack/assets/`.

### 2. **Erreur MIME Type (CSS non chargé)**
Dans la console du navigateur :

```
Refused to apply style from 'https://preprod2.univ-lorawan.fr/assets/index-C-P4JNPO.css' because its MIME type ('text/plain') is not a supported stylesheet MIME type, and strict MIME checking is enabled.
```

Cela indique que le `Content-Type` des fichiers CSS est incorrect.

---

## Solutions essayées

###  **Solution 1 : Modifier le `basePath` de ChirpStack**

Dans la configuration **ChirpStack** (`chirpstack.toml`), nous avons défini :

```toml
[web]
basePath = "/chirpstack/"
```

**Explication :**
- Cela force ChirpStack à générer les chemins des assets en ajoutant `/chirpstack/` devant.
- Ainsi, les fichiers seront accessibles sous `https://preprod2.univ-lorawan.fr/chirpstack/assets/`.

---

###  **Solution 2 : Corriger les règles Traefik**

Nous avons mis à jour `docker-compose.yml` pour inclure des middlewares qui corrigent les chemins et forcent le bon `Content-Type`.

```yaml
services:
  chirpstack:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.chirpstack.rule=Host(`preprod2.univ-lorawan.fr`) && PathPrefix(`/chirpstack`)"
      - "traefik.http.routers.chirpstack.entrypoints=websecure"
      - "traefik.http.routers.chirpstack.tls.certresolver=myresolver"
      - "traefik.http.services.chirpstack.loadbalancer.server.port=8080"

      # Middleware pour enlever /chirpstack des requêtes
      - "traefik.http.middlewares.chirpstack-stripprefix.stripprefix.prefixes=/chirpstack"

      # Middleware pour réécrire les chemins correctement
      - "traefik.http.middlewares.chirpstack-rewrite.replacepathregex.regex=^/chirpstack/(.*)"
      - "traefik.http.middlewares.chirpstack-rewrite.replacepathregex.replacement=/\1"

      # Middleware pour fixer le Content-Type
      - "traefik.http.middlewares.chirpstack-headers.headers.customresponseheaders.X-Content-Type-Options=nosniff"

      # Application des middlewares
      - "traefik.http.routers.chirpstack.middlewares=chirpstack-stripprefix,chirpstack-rewrite,chirpstack-headers"
```

**Explication :**
- **`chirpstack-stripprefix`** : Supprime `/chirpstack` des requêtes avant de les envoyer au backend.
- **`chirpstack-rewrite`** : Réécrit les chemins pour éviter les erreurs de routage.
- **`chirpstack-headers`** : Corrige les en-têtes HTTP pour éviter l'erreur MIME sur les CSS/JS.

---

## 🔄 Procédure après modifications

1. **Redémarrer Traefik et ChirpStack** :
   ```bash
   docker-compose down && docker-compose up -d
   ```
2. **Vérifier les logs en direct** :
   ```bash
   docker logs -f traefik
   ```
3. **Recharger la page avec un hard refresh** :
   - **Windows/Linux** : `Ctrl + Shift + R`
   - **Mac** : `Cmd + Shift + R`

---

##  Conclusion

Malgré les corrections apportées, le problème de chargement des assets persiste. Les fichiers CSS et JS continuent de ne pas se charger correctement via Traefik. 

Le meme porblème de path existe avec influxdb. 

Voici des liens qui s'exprime sur le sujet sur les forums d'influxdb : 

https://github.com/influxdata/influxdb/issues/15721

https://github.com/influxdata/influxdb/issues/21009

