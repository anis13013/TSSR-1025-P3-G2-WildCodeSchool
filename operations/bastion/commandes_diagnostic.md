# Commandes de Diagnostic Avancées — Serveur Bastion

Ce document regroupe les commandes techniques pour un diagnostic approfondi du bastion.

---

## Table des matières

- [1. Logs Docker](#1-logs-docker)
- [2. Connexion aux conteneurs](#2-connexion-aux-conteneurs)
- [3. Tests réseau](#3-tests-réseau)
- [4. Vérification des certificats](#4-vérification-des-certificats)
- [5. État de la base de données](#5-état-de-la-base-de-données)
- [6. Analyse des volumes Docker](#6-analyse-des-volumes-docker)

---

## 1. Logs Docker

### Voir les logs de tous les conteneurs

```bash
cd /opt/guacamole

# Logs complets
docker compose logs

# 100 dernières lignes
docker compose logs --tail 100

# Suivre les logs en temps réel
docker compose logs -f

# Logs avec timestamps
docker compose logs -t
```

---

### Logs d'un conteneur spécifique

```bash
# Nginx (50 dernières lignes)
docker compose logs nginx --tail 50

# Guacamole (100 dernières lignes avec timestamps)
docker compose logs guacamole --tail 100 -t

# guacd (suivi en temps réel)
docker compose logs guacd -f

# PostgreSQL (200 dernières lignes)
docker compose logs postgres --tail 200
```

---

### Filtrer les logs par mot-clé

```bash
# Rechercher les erreurs
docker compose logs | grep -i error

# Rechercher les warnings
docker compose logs | grep -i warn

# Rechercher les connexions RDP
docker compose logs guacd | grep -i rdp

# Rechercher les connexions SSH
docker compose logs guacd | grep -i ssh

# Rechercher les authentifications
docker compose logs guacamole | grep -i auth
```

---

### Exporter les logs

```bash
# Exporter tous les logs dans un fichier
docker compose logs > /tmp/bastion_logs_$(date +%Y%m%d_%H%M%S).txt

# Exporter seulement les erreurs
docker compose logs | grep -i error > /tmp/bastion_errors_$(date +%Y%m%d).txt

# Logs des dernières 24h
docker compose logs --since 24h > /tmp/bastion_logs_24h.txt

# Logs entre deux dates
docker compose logs --since "2026-02-20T00:00:00" --until "2026-02-27T23:59:59" > /tmp/bastion_logs_week.txt
```

---

## 2. Connexion aux conteneurs

### Ouvrir un shell dans un conteneur

**Nginx (Alpine Linux) :**

```bash
docker compose exec nginx sh

# Une fois dans le conteneur :
cd /etc/nginx
cat nginx.conf
ls -la /etc/nginx/ssl/
nginx -t  # Tester la config Nginx
exit
```

---

**Guacamole :**

```bash
docker compose exec guacamole bash

# Une fois dans le conteneur :
env | grep POSTGRES
env | grep GUACD
cat /opt/tomcat/logs/catalina.out
exit
```

---

**PostgreSQL :**

```bash
docker compose exec postgres bash

# Une fois dans le conteneur :
psql -U guacamole_user -d guacamole_db
# Ou directement :
docker compose exec postgres psql -U guacamole_user -d guacamole_db
```

---

**guacd :**

```bash
docker compose exec guacd bash

# Une fois dans le conteneur :
ps aux
netstat -tlnp
exit
```

---

### Exécuter une commande sans entrer dans le conteneur

```bash
# Tester la config Nginx
docker compose exec nginx nginx -t

# Lister les processus dans guacd
docker compose exec guacd ps aux

# Vérifier la version PostgreSQL
docker compose exec postgres psql --version

# Tester la connexion PostgreSQL
docker compose exec postgres pg_isready -U guacamole_user
```

---

## 3. Tests réseau

### Tests depuis l'hôte bastion

**Connectivité générale :**

```bash
# Passerelle pfSense
ping -c 3 10.50.20.1

# DNS
nslookup bastion.ecotech.local
dig bastion.ecotech.local +short

# Internet
curl -I https://www.google.com

# Serveurs internes
ping -c 3 10.20.20.5
ping -c 3 10.20.20.7
```

---

**Tests de ports :**

```bash
# RDP (port 3389)
nc -zv 10.20.20.5 3389
timeout 2 bash -c "</dev/tcp/10.20.20.5/3389" && echo "Port 3389 ouvert" || echo "Port 3389 fermé"

# SSH (port 22)
nc -zv 10.20.20.7 22
timeout 2 bash -c "</dev/tcp/10.20.20.7/22" && echo "Port 22 ouvert" || echo "Port 22 fermé"

# LDAP (port 389) - pour tester AD
nc -zv 10.20.20.5 389
```

---

**Ports ouverts sur le bastion :**

```bash
# Méthode 1 : netstat
netstat -tlnp | grep -E "443|80"

# Méthode 2 : ss (plus moderne)
ss -tlnp | grep -E "443|80"

# Méthode 3 : lsof
lsof -i -P -n | grep LISTEN
```

---

**Connexions actives :**

```bash
# Connexions établies
netstat -an | grep ESTABLISHED

# Connexions vers le port 443
netstat -an | grep :443

# Nombre de connexions par état
netstat -an | awk '{print $6}' | sort | uniq -c
```

---

### Tests depuis les conteneurs

**Depuis Nginx vers Guacamole :**

```bash
# Test HTTP
docker compose exec nginx wget -O- http://guacamole:8080/guacamole

# Test de résolution DNS interne
docker compose exec nginx nslookup guacamole

# Test de ping (si installé)
docker compose exec nginx ping -c 2 guacamole
```

---

**Depuis Guacamole vers guacd :**

```bash
# Test port 4822
docker compose exec guacamole nc -zv guacd 4822

# Alternative avec telnet
docker compose exec guacamole telnet guacd 4822
```

---

**Depuis Guacamole vers PostgreSQL :**

```bash
# Test port 5432
docker compose exec guacamole nc -zv postgres 5432

# Test de résolution DNS
docker compose exec guacamole nslookup postgres
```

---

### Analyse du trafic réseau

**Capture de paquets sur l'interface du bastion :**

```bash
# Installer tcpdump si nécessaire
apt install -y tcpdump

# Capturer le trafic HTTPS (port 443)
tcpdump -i eth0 port 443 -w /tmp/bastion_https_$(date +%Y%m%d).pcap

# Capturer le trafic vers un serveur spécifique
tcpdump -i eth0 host 10.20.20.5 -w /tmp/traffic_ad.pcap

# Afficher en temps réel (sans sauvegarder)
tcpdump -i eth0 port 443 -n
```

---

**Surveiller les connexions Docker :**

```bash
# Voir le réseau Docker
docker network ls

# Inspecter le réseau guacamole_net
docker network inspect guacamole_guacamole_net

# Voir les IPs des conteneurs
docker compose exec nginx ip addr
docker compose exec guacamole ip addr
```

---

## 4. Vérification des certificats

### Informations basiques

```bash
# Date d'expiration
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -dates

# Sujet (CN, O, OU...)
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -subject

# Émetteur (pour certificats signés par CA)
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -issuer

# Numéro de série
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -serial
```

---

### Informations complètes

```bash
# Tout afficher (très verbeux)
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -text

# Afficher le certificat au format lisible
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -text | less

# Afficher uniquement les extensions
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -text | grep -A 20 "X509v3 extensions"
```

---

### Vérifier la correspondance clé privée / certificat

```bash
# Hash MD5 du certificat
openssl x509 -in /opt/guacamole/ssl/certs/bastion.crt -noout -modulus | md5sum

# Hash MD5 de la clé privée
openssl rsa -in /opt/guacamole/ssl/private/bastion.key -noout -modulus | md5sum

# Les deux hash doivent être identiques ✅
```

**Si différents :** La clé privée ne correspond pas au certificat → Régénérer les deux

---

### Tester le certificat via HTTPS

```bash
# Test avec openssl s_client
openssl s_client -connect 10.50.20.5:443 -showcerts

# Afficher uniquement le certificat serveur
echo | openssl s_client -connect 10.50.20.5:443 2>/dev/null | openssl x509 -noout -dates

# Test avec curl (vérifier la validité)
curl -vI https://10.50.20.5 2>&1 | grep -i "certificate"
```

---

### Vérifier depuis un poste client

**Linux :**

```bash
# Télécharger le certificat
openssl s_client -connect bastion.ecotech.local:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > bastion_cert.pem

# Vérifier la date
openssl x509 -in bastion_cert.pem -noout -dates
```

---

**Windows PowerShell :**

```powershell
# Récupérer le certificat
$cert = (Invoke-WebRequest -Uri https://bastion.ecotech.local -SkipCertificateCheck).BaseResponse.ServicePoint.Certificate

# Afficher la date d'expiration
$cert.GetExpirationDateString()

# Afficher le sujet
$cert.Subject
```

---

## 5. État de la base de données

### Connexion et informations générales

```bash
# Connexion interactive
docker compose exec postgres psql -U guacamole_user -d guacamole_db

# Version PostgreSQL
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "SELECT version();"

# Taille de la base
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT pg_size_pretty(pg_database_size('guacamole_db')) AS db_size;
"
```

---

### Statistiques des tables

```bash
# Nombre d'entrées par table
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  schemaname,
  tablename,
  n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;
"
```

---

### Taille des tables

```bash
# Taille de chaque table
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"
```

---

### Données applicatives

**Nombre d'utilisateurs :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT COUNT(*) AS nb_users FROM guacamole_entity WHERE type = 'USER';
"
```

---

**Liste des utilisateurs :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT name AS username FROM guacamole_entity WHERE type = 'USER' ORDER BY name;
"
```

---

**Nombre de connexions configurées :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT COUNT(*) AS nb_connections FROM guacamole_connection;
"
```

---

**Liste des connexions :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  connection_name,
  protocol,
  CASE 
    WHEN protocol = 'rdp' THEN 'Windows RDP'
    WHEN protocol = 'ssh' THEN 'Linux SSH'
    WHEN protocol = 'vnc' THEN 'VNC'
    ELSE protocol
  END AS type
FROM guacamole_connection
ORDER BY connection_name;
"
```

---

**Sessions actives (utilisateurs connectés maintenant) :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  u.name AS username,
  c.connection_name,
  h.start_date,
  NOW() - h.start_date AS duration
FROM guacamole_connection_history h
JOIN guacamole_user u ON h.user_id = u.user_id
JOIN guacamole_connection c ON h.connection_id = c.connection_id
WHERE h.end_date IS NULL;
"
```

---

**Historique des 10 dernières connexions :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  u.name AS username,
  c.connection_name,
  h.start_date,
  h.end_date,
  h.end_date - h.start_date AS duration
FROM guacamole_connection_history h
JOIN guacamole_user u ON h.user_id = u.user_id
JOIN guacamole_connection c ON h.connection_id = c.connection_id
ORDER BY h.start_date DESC
LIMIT 10;
"
```

---

**Statistiques d'utilisation (30 derniers jours) :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  u.name AS username,
  c.connection_name,
  COUNT(*) AS nb_sessions,
  SUM(h.end_date - h.start_date) AS total_duration
FROM guacamole_connection_history h
JOIN guacamole_user u ON h.user_id = u.user_id
JOIN guacamole_connection c ON h.connection_id = c.connection_id
WHERE h.start_date > NOW() - INTERVAL '30 days'
GROUP BY u.name, c.connection_name
ORDER BY nb_sessions DESC;
"
```

---

### Performance de la base

**Connexions actives à PostgreSQL :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active';
"
```

---

**Liste des requêtes en cours :**

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  pid,
  usename,
  state,
  query,
  NOW() - query_start AS duration
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;
"
```

---

**Vérifier l'intégrité de la base :**

```bash
# Vérifier la cohérence des tables
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
" | xargs -I {} docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "VACUUM ANALYZE {};"
```

---

## 6. Analyse des volumes Docker

### Lister les volumes

```bash
# Tous les volumes
docker volume ls

# Volumes de Guacamole
docker volume ls | grep guacamole
```

---

### Inspecter un volume

```bash
# Détails du volume PostgreSQL
docker volume inspect guacamole_postgres_data
```

**Informations affichées :**
- `Mountpoint` : Chemin réel sur l'hôte
- `Driver` : Type de driver (local)
- `Name` : Nom du volume

---

### Taille des volumes

```bash
# Taille du volume PostgreSQL
docker volume inspect guacamole_postgres_data --format '{{ .Mountpoint }}' | xargs du -sh

# Espace disque Docker global
docker system df

# Détails par type
docker system df -v
```

---

### Sauvegarder un volume

```bash
# Sauvegarder le volume PostgreSQL en tar.gz
docker run --rm -v guacamole_postgres_data:/data -v /tmp:/backup alpine tar czf /backup/postgres_volume_$(date +%Y%m%d).tar.gz /data
```

---

### Restaurer un volume

```bash
# Créer un nouveau volume
docker volume create guacamole_postgres_data_restored

# Restaurer depuis tar.gz
docker run --rm -v guacamole_postgres_data_restored:/data -v /tmp:/backup alpine tar xzf /backup/postgres_volume_20260227.tar.gz -C /
```

---

**Pour les procédures de reprise complète :** Consulter le document `04-procedures-reprise.md`

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>