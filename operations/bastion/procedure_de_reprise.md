# Procédures de Reprise — Serveur Bastion

Ce document décrit les procédures de reprise après incident, du simple redémarrage à la reconstruction complète.

---

## Table des matières

- [1. Redémarrage des conteneurs](#1-redémarrage-des-conteneurs)
- [2. Reconstruction complète de la stack](#2-reconstruction-complète-de-la-stack)
- [3. Restauration depuis sauvegarde](#3-restauration-depuis-sauvegarde)
- [4. Migration vers un nouveau serveur](#4-migration-vers-un-nouveau-serveur)

---

## 1. Redémarrage des conteneurs

### Redémarrage simple

```bash
cd /opt/guacamole
docker compose restart
```

**Durée :** ~30 secondes  
**Impact :** Coupure temporaire  
**Données préservées :** ✅ Toutes

---

## 2. Reconstruction complète de la stack

```bash
cd /opt/guacamole
docker compose down
docker compose pull
docker compose up -d
```

---

## 3. Restauration depuis sauvegarde

### Restauration base de données

```bash
cd /opt/guacamole
docker compose stop guacamole
docker compose exec -T postgres psql -U guacamole_user -d guacamole_db < /backups/bastion/backup.sql
docker compose restart
```

---

## 4. Migration vers un nouveau serveur

Voir document installation.md pour procédure complète.

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
