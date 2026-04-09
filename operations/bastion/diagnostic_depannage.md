# Diagnostics et Dépannage — Serveur Bastion

Ce document présente les scénarios de panne les plus courants et leurs solutions.

---

## Table des matières

- [1. Le bastion ne répond plus (HTTPS)](#1-le-bastion-ne-répond-plus-https)
- [2. Impossible de se connecter à Guacamole](#2-impossible-de-se-connecter-à-guacamole)
- [3. Connexions RDP/SSH échouent](#3-connexions-rdpssh-échouent)
- [4. Certificat SSL expiré](#4-certificat-ssl-expiré)
- [5. Base de données PostgreSQL corrompue](#5-base-de-données-postgresql-corrompue)
- [6. Performances dégradées](#6-performances-dégradées)

---

## 1. Le bastion ne répond plus (HTTPS)

### Symptôme

`https://bastion.ecotech.local` ne charge pas, timeout, ou erreur de connexion.

---

### Diagnostic rapide

```bash
# 1. Vérifier l'état des conteneurs
docker compose ps

# 2. Vérifier que Nginx écoute sur le port 443
netstat -tlnp | grep :443

# 3. Vérifier les logs Nginx
docker compose logs nginx --tail 50

# 4. Test local depuis le bastion
curl -k -I https://localhost

# 5. Vérifier les règles pfSense
# (depuis pfSense) Firewall → Rules → ADMIN
# Vérifier la règle : ADMIN net → Bastion:443
```

---

### Solutions possibles

#### Si Nginx est arrêté

```bash
# Vérifier pourquoi Nginx est arrêté
docker compose logs nginx --tail 100

# Redémarrer Nginx
docker compose restart nginx

# Suivre les logs
docker compose logs nginx -f
```

---

#### Si le port 443 n'est pas ouvert

```bash
# Vérifier les règles iptables (peut interférer avec Docker)
iptables -L -n | grep 443

# Si conflit, redémarrer Docker
systemctl restart docker

# Redémarrer la stack
docker compose restart
```

---

#### Si erreur de configuration Nginx

```bash
# Tester la configuration Nginx
docker compose exec nginx nginx -t

# Si erreur, vérifier le fichier nginx.conf
cat /opt/guacamole/nginx.conf

# Corriger et redémarrer
docker compose restart nginx
```

---

#### Si problème de certificat

```bash
# Vérifier la validité du certificat
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -dates

# Si expiré, voir section 4 (Certificat SSL expiré)
```

---

## 2. Impossible de se connecter à Guacamole

### Symptôme

La page HTTPS s'affiche, mais :
- Page de login ne s'affiche pas
- Erreur 502 Bad Gateway
- Erreur 503 Service Unavailable

---

### Diagnostic rapide

```bash
# 1. Vérifier que Guacamole tourne
docker compose ps guacamole

# 2. Vérifier les logs Guacamole
docker compose logs guacamole --tail 100

# 3. Vérifier que PostgreSQL répond
docker compose exec postgres pg_isready -U guacamole_user

# 4. Test de connexion interne Nginx → Guacamole
docker compose exec nginx wget -O- http://guacamole:8080/guacamole

# 5. Vérifier que guacd tourne
docker compose ps guacd
```

---

### Solutions possibles

#### Si Guacamole est en erreur

```bash
# Redémarrer Guacamole
docker compose restart guacamole

# Vérifier les logs en temps réel
docker compose logs guacamole -f
```

**Erreurs courantes dans les logs :**
- `Connection refused` → PostgreSQL ne répond pas
- `Authentication failed` → Mauvais mot de passe PostgreSQL
- `guacd is not available` → guacd ne répond pas

---

#### Si PostgreSQL ne répond pas

```bash
# Redémarrer PostgreSQL
docker compose restart postgres

# Attendre 10 secondes
sleep 10

# Vérifier les logs
docker compose logs postgres --tail 50

# Tester la connexion
docker compose exec postgres pg_isready -U guacamole_user
```

---

#### Si problème de connexion Guacamole → PostgreSQL

```bash
# Vérifier les variables d'environnement
docker compose exec guacamole env | grep POSTGRES

# Vérifier le docker-compose.yml
cat /opt/guacamole/docker-compose.yml | grep -A 10 "environment:"

# Si erreur de configuration, corriger et recréer
nano /opt/guacamole/docker-compose.yml
docker compose up -d --force-recreate guacamole
```

---

## 3. Connexions RDP/SSH échouent

### Symptôme

L'authentification Guacamole fonctionne, mais les connexions aux serveurs échouent :
- Message "Connection failed"
- Message "Permission denied"
- Écran noir sans réponse

---

### Diagnostic rapide

```bash
# 1. Vérifier que guacd tourne
docker compose ps guacd

# 2. Vérifier les logs guacd
docker compose logs guacd --tail 100

# 3. Test de connectivité réseau depuis le bastion
ping -c 3 10.20.20.5
nc -zv 10.20.20.5 3389
nc -zv 10.20.20.7 22

# 4. Vérifier les règles pfSense (depuis pfSense)
# Firewall → Rules → BASTION
# Vérifier les règles RDP (3389) et SSH (22)

# 5. Vérifier les logs pfSense
# Status → System Logs → Firewall
# Filtrer par interface BASTION
# Rechercher des blocages (icône ❌)
```

---

### Solutions possibles

#### Si guacd est arrêté

```bash
# Redémarrer guacd
docker compose restart guacd

# Suivre les logs
docker compose logs guacd -f
```

---

#### Si problème de réseau

```bash
# Vérifier la route par défaut
ip route show

# Vérifier que la passerelle répond
ping 10.50.20.1

# Vérifier les règles iptables
iptables -L -n

# Redémarrer le réseau Docker
docker compose down
docker compose up -d
```

---

#### Si règles pfSense bloquent

**Sur pfSense :**
1. **Firewall** → **Rules** → **BASTION**
2. Vérifier que les règles suivantes existent :
   - RDP : `Pass TCP BASTION net → 10.20.0.0/16 : 3389`
   - SSH : `Pass TCP BASTION net → 10.20.0.0/16 : 22`
3. **Status** → **System Logs** → **Firewall**
4. Filtrer par `BASTION` et chercher des blocages

**Si règles manquantes :** Voir document `installation.md` section 7 (Règles pare-feu)

---

#### Si problème d'authentification sur le serveur cible

```bash
# Vérifier la configuration de la connexion dans Guacamole
# Settings → Connections → [Nom de la connexion]
# Vérifier :
# - IP correcte
# - Port correct (3389 pour RDP, 22 pour SSH)
# - Username correct
# - Password correct
# - Domaine correct (pour RDP Windows)
```

**Test manuel depuis le bastion :**

```bash
# RDP (Windows)
apt install -y freerdp2-x11
xfreerdp /v:10.20.20.5 /u:Administrateur /d:ECOTECH

# SSH (Linux)
ssh root@10.20.20.7
```

---

## 4. Certificat SSL expiré

### Symptôme

Le navigateur affiche :
- "Votre connexion n'est pas privée"
- "NET::ERR_CERT_DATE_INVALID"
- "Le certificat a expiré"

---

### Diagnostic

```bash
# Vérifier la date d'expiration
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -dates
```

**Résultat :**

```
notBefore=Feb 23 10:00:00 2025 GMT
notAfter=Feb 23 10:00:00 2026 GMT
```

**Interprétation :**
- Si `notAfter` est dans le passé → Certificat expiré ❌
- Si `notAfter` est dans moins de 30 jours → Renouveler bientôt ⚠️

---

### Solution : Renouvellement du certificat

```bash
cd /opt/guacamole/ssl

# Sauvegarder l'ancien certificat
mv certs/bastion.crt certs/bastion.crt.$(date +%Y%m%d)
mv private/bastion.key private/bastion.key.$(date +%Y%m%d)

# Générer un nouveau certificat
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout private/bastion.key \
  -out certs/bastion.crt \
  -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/OU=IT/CN=bastion.ecotech.local"

# Vérifier la nouvelle date d'expiration
openssl x509 -in certs/bastion.crt -noout -dates

# Redémarrer Nginx
docker compose restart nginx

# Vérifier depuis un navigateur
# https://bastion.ecotech.local
```

---

### Automatiser le renouvellement

**Créer un script de vérification :**

```bash
cat > /usr/local/bin/check-cert-bastion.sh << 'EOFSCRIPT'
#!/bin/bash

CERT="/opt/guacamole/ssl/certs/bastion.crt"
DAYS_BEFORE_EXPIRY=30

# Vérifier la date d'expiration
EXPIRY_DATE=$(openssl x509 -in $CERT -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_BEFORE_EXPIRY ]; then
    echo "⚠️ Certificat expire dans $DAYS_LEFT jours !"
    echo "Exécuter : cd /opt/guacamole/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout private/bastion.key -out certs/bastion.crt"
else
    echo "✅ Certificat valide encore $DAYS_LEFT jours"
fi
EOFSCRIPT

chmod +x /usr/local/bin/check-cert-bastion.sh

# Ajouter au cron (vérification hebdomadaire)
crontab -e
# Ajouter : 0 9 * * 1 /usr/local/bin/check-cert-bastion.sh
```

---

## 5. Base de données PostgreSQL corrompue

### Symptôme

- Guacamole ne démarre pas
- Erreurs dans les logs : "database corrupted", "checksum failure"
- Impossible de se connecter à PostgreSQL

---

### Diagnostic

```bash
# Tenter une connexion
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "SELECT 1"

# Vérifier les logs PostgreSQL
docker compose logs postgres --tail 200 | grep -i error
```

**Erreurs courantes :**
- `FATAL: database does not exist`
- `PANIC: could not locate a valid checkpoint record`
- `ERROR: invalid page in block`

---

### Solution 1 : Restauration depuis sauvegarde

**Si sauvegarde disponible :**

```bash
# Arrêter Guacamole
docker compose stop guacamole

# Supprimer la base corrompue
docker compose exec postgres psql -U guacamole_user -d postgres -c "DROP DATABASE guacamole_db;"

# Recréer la base
docker compose exec postgres psql -U guacamole_user -d postgres -c "CREATE DATABASE guacamole_db;"

# Restaurer depuis sauvegarde
docker compose exec -T postgres psql -U guacamole_user -d guacamole_db < /backups/bastion/guacamole_db_20260227.sql

# Redémarrer tout
docker compose restart
```

---

### Solution 2 : Réinitialisation complète

**⚠️ ATTENTION : Perte de TOUTES les configurations Guacamole**

```bash
# Sauvegarder ce qui est possible (peut échouer si base très corrompue)
docker compose exec postgres pg_dumpall -U guacamole_user > /tmp/rescue_$(date +%Y%m%d).sql

# Arrêter tout
docker compose down

# Supprimer le volume PostgreSQL
docker volume rm guacamole_postgres_data

# Relancer PostgreSQL
docker compose up -d postgres
sleep 10

# Réinjecter le schéma Guacamole
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > initdb.sql
docker compose exec -T postgres psql -U guacamole_user -d guacamole_db < initdb.sql

# Relancer tout
docker compose up -d

# ⚠️ Il faudra reconfigurer manuellement :
# - Changer le mot de passe guacadmin
# - Recréer les utilisateurs
# - Recréer les groupes
# - Recréer les connexions
```

---

## 6. Performances dégradées

### Symptôme

- Interface Guacamole lente
- Connexions RDP/SSH saccadées
- Timeouts fréquents

---

### Diagnostic

```bash
# Vérifier la charge système
top -bn1 | head -20

# Vérifier la RAM disponible
free -h

# Vérifier les conteneurs
docker stats --no-stream

# Vérifier l'espace disque
df -h

# Vérifier les connexions actives
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT COUNT(*) FROM guacamole_connection_history WHERE end_date IS NULL;
"
```

---

### Solutions possibles

#### Si conteneur saturé en CPU/RAM

```bash
# Redémarrer le conteneur problématique
docker compose restart guacamole

# Si problème persiste, limiter les ressources
nano /opt/guacamole/docker-compose.yml

# Ajouter des limites (exemple pour guacamole)
# deploy:
#   resources:
#     limits:
#       cpus: '2.0'
#       memory: 1G

# Relancer
docker compose up -d
```

---

#### Si manque d'espace disque

```bash
# Nettoyer les images Docker inutilisées
docker system prune -a

# Nettoyer les logs anciens
find /var/lib/docker/containers/ -name "*.log" -mtime +30 -delete

# Nettoyer les anciennes sauvegardes
find /backups/bastion/ -name "*.sql" -mtime +60 -delete
```

---

#### Si trop de sessions actives

```bash
# Voir les sessions actives
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT u.name, c.connection_name, h.start_date
FROM guacamole_connection_history h
JOIN guacamole_user u ON h.user_id = u.user_id
JOIN guacamole_connection c ON h.connection_id = c.connection_id
WHERE h.end_date IS NULL;
"

# Forcer la fermeture des sessions zombies (redémarrage guacd)
docker compose restart guacd
```

---

**Pour des commandes de diagnostic plus avancées :** Consulter le document `03-commandes-diagnostic.md`

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>