
# Script Bash pour Installer et Utiliser `traefik-certs-dumper`

Ce script Bash permet :  
1. D'installer automatiquement `traefik-certs-dumper` s'il n'est pas déjà installé.  
2. D'exécuter la commande `traefik-certs-dumper` pour extraire les certificats depuis un fichier `acme.json`.  
3. De copier automatiquement les certificats générés vers un répertoire cible spécifique.  

⚠️ **Attention** : Toutes les fonctionnalités du script n'ont pas été entièrement testées. Des ajustements peuvent être nécessaires en fonction de la configuration de l'environnement.  

---

## 📄 **Contenu du Script**
### **Script : `traefik_certs_dumper.sh`**
```bash
#!/bin/bash

# Définir les variables
SOURCE_FILE="/chemin/vers/acme.json"
DEST_DIR="/chemin/vers/pem"
TARGET_DIR="/chemin/vers/cible"
DOMAIN="prepod2.univ.fr" # Définir le domaine ici
DUMPER_VERSION="v3.4.1" # Adapter à la dernière version disponible
DUMPER_BIN="/usr/local/bin/traefik-certs-dumper"

# Fonction pour installer traefik-certs-dumper
install_traefik_certs_dumper() {
    echo "Vérification de l'installation de traefik-certs-dumper..."

    if ! command -v traefik-certs-dumper &> /dev/null; then
        echo "Installation de traefik-certs-dumper..."

        # Télécharger le binaire depuis GitHub
        curl -s -L -o traefik-certs-dumper.tar.gz \
          "https://github.com/ldez/traefik-certs-dumper/releases/download/${DUMPER_VERSION}/traefik-certs-dumper_linux_amd64.tar.gz"

        # Extraire et déplacer le binaire
        tar -xzf traefik-certs-dumper.tar.gz
        sudo mv traefik-certs-dumper "$DUMPER_BIN"
        sudo chmod +x "$DUMPER_BIN"

        # Nettoyer le fichier téléchargé
        rm traefik-certs-dumper.tar.gz

        echo "traefik-certs-dumper installé avec succès dans $DUMPER_BIN"
    else
        echo "traefik-certs-dumper est déjà installé"
    fi
}

# Appeler la fonction d'installation
install_traefik_certs_dumper

# Créer les répertoires si nécessaire
mkdir -p "$DEST_DIR"
mkdir -p "$TARGET_DIR"

# Exécuter la commande traefik-certs-dumper
sudo traefik-certs-dumper file \
  --source "$SOURCE_FILE" \
  --dest "$DEST_DIR" \
  --version v3 \
  --domain-subdir \
  --crt-ext=.pem \
  --key-ext=.pem

# Vérification du succès de la commande
if [ $? -ne 0 ]; then
  echo "Erreur lors de l'exécution de traefik-certs-dumper"
  exit 1
fi

# Vérifier si le dossier du domaine existe
DOMAIN_DIR="$DEST_DIR/$DOMAIN"

if [ -d "$DOMAIN_DIR" ]; then
  # Copier uniquement le contenu du dossier de domaine
  cp -r "$DOMAIN_DIR"/* "$TARGET_DIR"
  
  if [ $? -eq 0 ]; then
    echo "Certificats copiés avec succès depuis $DOMAIN_DIR → $TARGET_DIR"
  else
    echo "Erreur lors de la copie des certificats"
    exit 1
  fi
else
  echo "Le dossier du domaine $DOMAIN n'existe pas dans $DEST_DIR"
  exit 1
fi
```

---

##  **Explication du Fonctionnement**
### 🔹 **Variables**  
- `SOURCE_FILE` → Chemin vers le fichier `acme.json` généré par Traefik contenant les certificats.  
- `DEST_DIR` → Dossier où `traefik-certs-dumper` va extraire les certificats.  
- `TARGET_DIR` → Dossier de destination où seront copiés les certificats extraits.  
- `DOMAIN` → Nom de domaine à utiliser pour localiser le dossier généré.  
- `DUMPER_VERSION` → Version du `traefik-certs-dumper` à installer.  
- `DUMPER_BIN` → Emplacement du binaire après installation.  

---

### 🔹 **Installation de `traefik-certs-dumper`**
1. Vérifie si le binaire est déjà installé en utilisant `command -v`.  
2. Si le binaire n'est pas trouvé, le script :  
   - Télécharge le binaire depuis GitHub.  
   - Décompresse l'archive.  
   - Place le binaire dans `/usr/local/bin` et le rend exécutable.  

---

###  **Exécution de `traefik-certs-dumper`**
- La commande `traefik-certs-dumper` est exécutée avec les options suivantes :  
  - `--source` → Fichier `acme.json` comme source.  
  - `--dest` → Dossier de destination des certificats.  
  - `--version` → Version du format utilisé.  
  - `--domain-subdir` → Crée un sous-dossier par nom de domaine.  
  - `--crt-ext` et `--key-ext` → Extensions `.pem` pour les certificats et clés.  

---

### 🔹 **Copie des Certificats**
1. Le script vérifie si le dossier du domaine existe dans le répertoire de destination.  
2. Si le dossier est trouvé, il copie son contenu vers le dossier cible (`TARGET_DIR`).  
3. Si la copie échoue, un message d'erreur est affiché.  

---

###  **Limitations Connues**
- La version de `traefik-certs-dumper` est définie manuellement dans le script.  
- La gestion des erreurs pourrait être améliorée en fonction des cas d'utilisation.  
- Le script suppose que le fichier `acme.json` est valide et contient des certificats exploitables.  

---

##  **Instructions d'Utilisation**
1. Copier le code dans un fichier nommé `traefik_certs_dumper.sh`.  
2. Rendre le script exécutable :  
```bash
chmod +x traefik_certs_dumper.sh
```
3. Lancer le script :  
```bash
./traefik_certs_dumper.sh
```

---

## 🚨 **Avertissement**
Toutes les fonctionnalités du script n'ont pas été entièrement testées. Des ajustements peuvent être nécessaires en fonction de votre configuration et de l'environnement réseau.  
