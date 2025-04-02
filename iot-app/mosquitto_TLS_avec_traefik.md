## Configuration de Mosquitto avec TLS via Traefik

Dans cette partie, nous allons voir comment mettre en place un Mosquitto TLS passant par Traefik. On se connectera depuis l'extérieur sur le port **8883**. Notre conteneur Docker Mosquitto écoutera sur le port **1883** en MQTT sans TLS.

### Configuration de Mosquitto

Il suffit que Mosquitto écoute sur le port 1883 en MQTT. Voici une configuration d'exemple :

```ini
listener 1883 0.0.0.0
protocol mqtt
#allow_anonymous true
password_file /mosquitto/config/passdb
acl_file /mosquitto/config/authorization.acl
#log_type all
```

### Configuration de Traefik

Il faut ouvrir le port **8883** sur le conteneur Traefik pour permettre la redirection. Voici une configuration d'exemple :

```yaml
reverse-proxy:
    image: traefik:v3.1
    command:
      - --api.insecure=true
      - --providers.docker
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --entrypoints.mqtt.address=:8883 # Déclaration du port MQTT
      #- --entrypoints.mqtt.alpn=protocol
      - --certificatesresolvers.myresolver.acme.tlschallenge=true
      - --certificatesresolvers.myresolver.acme.email=louis.claudel@etu.univ-smb.fr
      - --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.myresolver.acme.caServer=https://acme-v02.api.letsencrypt.org/directory
      - --log.level=DEBUG
      - --accesslog=true
      - --accesslog.addinternals

    ports:
      - "80:80"
      - "443:443"
      - "8883:8883" # Ouverture du port 8883 sur Traefik
      - "8085:8080"
    volumes:
      - ./letsencrypt:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - mon-reseau
```

### Configuration du conteneur Mosquitto

Exemple de configuration pour un conteneur Docker Mosquitto :

```yaml
mosquitto-clients:
    image: eclipse-mosquitto:2
    restart: unless-stopped
    volumes:
      - ./mosquitto-clients/config:/mosquitto/config
    environment:
      - TZ=Europe/Paris
    networks:
      - mon-reseau
    labels:
      - "traefik.enable=true"
      - "traefik.tcp.routers.mosquitto-clients.entrypoints=mqtt"
      - "traefik.tcp.routers.mosquitto-clients.rule=HostSNI(`*`)"
      - "traefik.tcp.routers.mosquitto-clients.tls=true"
      - "traefik.tcp.routers.mosquitto-clients.service=mosquitto-clients"
      - "traefik.tcp.routers.mosquitto-clients.tls.certresolver=myresolver"
      - "traefik.tcp.services.mosquitto-clients.loadbalancer.server.port=1883"
```

### Fonctionnement

Lorsque Traefik reçoit des paquets TCP sur le port MQTT (**8883**), il les redirige vers le port **1883** du conteneur Mosquitto. Le routage TCP se fait avant le routage HTTP sur Traefik.

Vous pouvez maintenant vous connecter en **MQTT TLS** à votre Mosquitto en passant par Traefik.


