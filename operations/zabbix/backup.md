# Procédure de sauvegarde de la base de données Zabbix

### 1. Sauvegarde quotidienne

**Commande de sauvegarde :**

    mysqldump -u zabbix -p'VotreMotDePasseTresFort' --single-transaction --quick zabbix > /backups/zabbix-$(date +%Y-%m-%d).sql


**Puis compression :**

    gzip /backups/zabbix-$(date +%Y-%m-%d).sql


**Suppression automatique des anciennes sauvegardes :**

    find /backups/zabbix -name "*.sql.gz" -mtime +30 -delete


### 2. Sauvegarde manuelle (en cas d'urgence)

    mysqldump -u zabbix -p --single-transaction zabbix > /backups/zabbix-urgence-$(date +%Y%m%d).sql


### 3. Restauration complète

**Arrêter les services :**

    systemctl stop zabbix-server zabbix-agent


**Restaurer la base :**

    mysql -u zabbix -p zabbix < /backups/zabbix-2026-02-16.sql


**Redémarrer les services :**

    systemctl start zabbix-server zabbix-agent


### 4. Emplacements et rétention

**Dossier de sauvegarde : /backups/zabbix/**

Rétention : 30 jours (automatique)

**Test de restauration** : À réaliser tous les trimestres.


