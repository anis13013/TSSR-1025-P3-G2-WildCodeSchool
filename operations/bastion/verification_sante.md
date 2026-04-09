# Vérifications de Santé — Serveur Bastion

Ce document regroupe toutes les commandes de vérification pour s'assurer du bon fonctionnement du bastion. À exécuter régulièrement ou avant toute intervention.

---

## Table des matières

- [1. État des conteneurs Docker](#1-état-des-conteneurs-docker)
- [2. État des services système](#2-état-des-services-système)
- [3. Connectivité réseau](#3-connectivité-réseau)
- [4. Utilisation des ressources](#4-utilisation-des-ressources)
- [5. Intégrité de la base de données](#5-intégrité-de-la-base-de-données)
- [6. Checklist de vérification rapide](#6-checklist-de-vérification-rapide)

---

## 1. État des conteneurs Docker

### Vérifier que tous les conteneurs sont actifs

```bash
cd /opt/guacamole
docker compose ps
```

**Résultat attendu :**

```
NAME                  IMAGE                    STATUS
nginx_reverse_proxy   nginx:alpine             Up
guacamole             guacamole/guacamole      Up
guacd                 guacamole/guacd          Up
postgres_guacamole    postgres:15-alpine       Up
```

**✅ OK :** Les 4 conteneurs sont en état `Up`  
**❌ Problème :** Un ou plusieurs conteneurs sont en état `Exited`, `Restarting` ou absents

---

### Vérifier l'uptime et les redémarrages

```bash
docker compose ps -a
```

**Interprétation :**
- Si un conteneur redémarre en boucle, il y a un problème de configuration ou de dépendance
- Un conteneur avec un uptime très court indique des redémarrages récents

---

### Vérifier les images Docker utilisées

```bash
docker compose images
```

**Résultat attendu :** Versions cohérentes et pas trop anciennes

---

## 2. État des services système

### Vérifier que Docker tourne

```bash
systemctl status docker
```

**Résultat attendu :** `Active: active (running)`

---

### Vérifier les processus Docker

```bash
ps aux | grep docker
```

**Résultat attendu :** Plusieurs processus `dockerd` et `containerd` actifs

---

### Vérifier l'espace disque système

```bash
df -h /
df -h /var/lib/docker
df -h /opt/guacamole
```

**⚠️ Alerte si :** Espace disque < 20% disponible

---

## 3. Connectivité réseau

### Tests depuis le bastion lui-même

```bash
# Test de la passerelle pfSense
ping -c 3 10.50.20.1

# Test DNS
nslookup google.com
dig google.com

# Test Internet
curl -I https://www.google.com

# Test vers serveurs internes
ping -c 3 10.20.20.5
ping -c 3 10.20.20.7

# Test des ports RDP et SSH
nc -zv 10.20.20.5 3389
nc -zv 10.20.20.7 22
```

**Résultat attendu :** Tous les tests réussissent

---

### Tests depuis un poste administrateur

**Windows PowerShell :**

```powershell
# Test HTTPS vers le bastion
Test-NetConnection -ComputerName 10.50.20.5 -Port 443

# Test DNS
nslookup bastion.ecotech.local

# Test de résolution et accès
Resolve-DnsName bastion.ecotech.local

# Test HTTP (doit rediriger vers HTTPS)
Invoke-WebRequest http://10.50.20.5 -UseBasicParsing
```

**Linux :**

```bash
# Test HTTPS
curl -k -I https://bastion.ecotech.local

# Test DNS
nslookup bastion.ecotech.local

# Test de connectivité
nc -zv 10.50.20.5 443
```

**Résultat attendu :** 
- DNS résout correctement vers `10.50.20.5`
- Port 443 accessible
- HTTP redirige vers HTTPS

---

### Vérifier les ports ouverts sur le bastion

```bash
# Ports en écoute
netstat -tlnp | grep -E "443|80"

# Connexions actives
netstat -an | grep ESTABLISHED | grep -E ":443|:8080"

# Alternative avec ss
ss -tlnp | grep -E "443|80"
```

**Résultat attendu :**
- Port 443 en écoute (nginx)
- Port 80 en écoute (nginx - redirection)
- Port 8080 **NON exposé** à l'extérieur (uniquement Docker interne)

---

## 4. Utilisation des ressources

### Consommation CPU/RAM des conteneurs

```bash
docker stats --no-stream
```

**Résultat typique :**

```
CONTAINER           CPU %    MEM USAGE / LIMIT     MEM %
nginx_reverse_proxy 0.05%    5MiB / 3.8GiB        0.13%
guacamole           1.2%     450MiB / 3.8GiB      11.5%
guacd               0.8%     80MiB / 3.8GiB       2.05%
postgres_guacamole  0.3%     120MiB / 3.8GiB      3.07%
```

**⚠️ Alerte si :**
- CPU > 80% de manière soutenue
- MEM % > 90%
- Conteneur en swap (SWAP column non-nulle)

---

### Consommation CPU/RAM du système

```bash
# Vue d'ensemble
top -bn1 | head -20

# Utilisation RAM
free -h

# Utilisation CPU
mpstat 1 5
```

---

### Espace disque

```bash
df -h
```

**⚠️ Alerte si :**
- `/` < 20% disponible
- `/var/lib/docker` < 20% disponible
- `/opt/guacamole` < 10% disponible

---

### Taille des volumes Docker

```bash
# Liste des volumes
docker volume ls

# Taille du volume PostgreSQL
docker volume inspect guacamole_postgres_data

# Espace disque Docker global
docker system df
```

---

## 5. Intégrité de la base de données

### Connexion à PostgreSQL

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db
```

**Résultat attendu :** Prompt PostgreSQL `guacamole_db=#`

---

### Vérifications SQL basiques

**Nombre d'utilisateurs :**

```sql
SELECT COUNT(*) FROM guacamole_entity WHERE type = 'USER';
```

**Nombre de connexions configurées :**

```sql
SELECT COUNT(*) FROM guacamole_connection;
```

**Nombre de groupes d'utilisateurs :**

```sql
SELECT COUNT(*) FROM guacamole_entity WHERE type = 'USER_GROUP';
```

**Sessions actives (utilisateurs connectés maintenant) :**

```sql
SELECT COUNT(*) FROM guacamole_connection_history WHERE end_date IS NULL;
```

**Quitter PostgreSQL :**

```sql
\q
```

---

### Statistiques détaillées de la base

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT 
  'Users' AS table_name, COUNT(*) AS count FROM guacamole_entity WHERE type='USER'
UNION ALL
SELECT 'Connections', COUNT(*) FROM guacamole_connection
UNION ALL
SELECT 'Connection Groups', COUNT(*) FROM guacamole_connection_group
UNION ALL
SELECT 'User Groups', COUNT(*) FROM guacamole_entity WHERE type='USER_GROUP'
UNION ALL
SELECT 'Active Sessions', COUNT(*) FROM guacamole_connection_history WHERE end_date IS NULL
UNION ALL
SELECT 'Total Sessions (last 30 days)', COUNT(*) FROM guacamole_connection_history 
  WHERE start_date > NOW() - INTERVAL '30 days';
"
```

---

### Taille de la base de données

```bash
docker compose exec postgres psql -U guacamole_user -d guacamole_db -c "
SELECT pg_size_pretty(pg_database_size('guacamole_db')) AS db_size;
"
```

---

### Test de connectivité PostgreSQL

```bash
# Test simple
docker compose exec postgres pg_isready -U guacamole_user

# Test depuis Guacamole
docker compose exec guacamole nc -zv postgres 5432
```

**Résultat attendu :** `accepting connections` ou `Connection successful`

---

## 6. Checklist de vérification rapide

**À exécuter avant toute intervention :**

```bash
# 1. État des conteneurs
docker compose ps

# 2. Logs récents (recherche d'erreurs)
docker compose logs --tail 50 | grep -i error

# 3. Ressources
docker stats --no-stream

# 4. Connectivité
ping -c 2 10.50.20.1
curl -k -I https://localhost

# 5. Base de données
docker compose exec postgres pg_isready -U guacamole_user
```

**Durée totale :** ~30 secondes

**Résultat attendu :**
- ✅ 4 conteneurs `Up`
- ✅ Aucune erreur critique dans les logs
- ✅ CPU < 80%, RAM < 90%
- ✅ Ping OK, HTTPS OK
- ✅ PostgreSQL `accepting connections`

---

**Si un problème est détecté :** Consulter le document `02-diagnostics-depannage.md`

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>