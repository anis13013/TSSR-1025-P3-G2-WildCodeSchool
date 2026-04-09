# Sauvegarde du Bastion — Procédures

Ce document décrit les procédures de sauvegarde manuelle, automatique et les recommandations.

---

## Table des matières

- [1. Sauvegarde de la base de données](#1-sauvegarde-de-la-base-de-données)
- [2. Sauvegarde complète de la configuration](#2-sauvegarde-complète-de-la-configuration)
- [3. Script de sauvegarde automatique](#3-script-de-sauvegarde-automatique)
- [4. Recommandations](#4-recommandations)

---

## 1. Sauvegarde de la base de données

### Sauvegarde manuelle

```bash
cd /opt/guacamole
docker compose exec postgres pg_dump -U guacamole_user guacamole_db > backup_guacamole_$(date +%Y%m%d).sql
```

**Contenu sauvegardé :**
- Utilisateurs et groupes
- Connexions configurées
- Permissions et droits
- Historique des sessions

---

### Vérifier la sauvegarde

```bash
ls -lh backup_guacamole_*.sql
head -n 20 backup_guacamole_*.sql
```

---

## 2. Sauvegarde complète de la configuration

### Sauvegarde manuelle complète

```bash
cd /opt
tar -czf guacamole_backup_$(date +%Y%m%d).tar.gz guacamole/
```

**Contenu sauvegardé :**
- Base de données PostgreSQL (volume)
- Configuration Nginx (nginx.conf)
- Certificats SSL
- Fichier docker-compose.yml

---

### Vérifier la sauvegarde

```bash
ls -lh guacamole_backup_*.tar.gz
tar -tzf guacamole_backup_*.tar.gz | head -n 20
```

---

## 3. Script de sauvegarde automatique

### Créer le script

```bash
cat > /usr/local/bin/backup-bastion.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backups/bastion"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p ${BACKUP_DIR}

# Sauvegarde base de données
echo "$(date) - Sauvegarde PostgreSQL..."
cd /opt/guacamole
docker compose exec -T postgres pg_dump -U guacamole_user guacamole_db > ${BACKUP_DIR}/guacamole_db_${DATE}.sql

# Sauvegarde complète
echo "$(date) - Sauvegarde configuration..."
tar -czf ${BACKUP_DIR}/guacamole_full_${DATE}.tar.gz /opt/guacamole

# Nettoyage
echo "$(date) - Nettoyage..."
find ${BACKUP_DIR} -name "guacamole_*" -type f -mtime +${RETENTION_DAYS} -delete

echo "$(date) - Terminé"
ls -lh ${BACKUP_DIR} | tail -n 5
EOF

chmod +x /usr/local/bin/backup-bastion.sh
```

---

### Automatiser avec cron

```bash
crontab -e
```

Ajouter :

```
0 2 * * * /usr/local/bin/backup-bastion.sh >> /var/log/backup-bastion.log 2>&1
```

**Explication :** Sauvegarde tous les jours à 2h du matin

---

### Tester le script

```bash
/usr/local/bin/backup-bastion.sh
```

Vérifier :

```bash
ls -lh /backups/bastion/
tail /var/log/backup-bastion.log
```

---

## 4. Recommandations

### Stockage

✅ **Bon :**
- Serveur de fichiers (10.20.30.5)
- NAS dédié
- Stockage distant

❌ **Mauvais :**
- Uniquement sur le bastion lui-même

---

### Fréquence

| Type | Fréquence | Rétention |
|------|-----------|-----------|
| Base de données | Quotidienne | 30 jours |
| Configuration complète | Hebdomadaire | 3 mois |
| Avant modifications | Manuel | Permanent |

---

### Tests de restauration

- Tester une restauration **tous les 6 mois**
- Vérifier l'intégrité **mensuellement**
- Documenter la procédure

---

### Checklist de sauvegarde

Avant toute intervention importante :

```bash
# 1. Sauvegarde urgente
docker compose exec postgres pg_dump -U guacamole_user guacamole_db > /tmp/backup_emergency_$(date +%Y%m%d).sql

# 2. Copier hors du bastion
scp /tmp/backup_emergency_*.sql root@10.20.30.5:/backups/bastion/

# 3. Vérifier
ls -lh /tmp/backup_emergency_*.sql
```

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>