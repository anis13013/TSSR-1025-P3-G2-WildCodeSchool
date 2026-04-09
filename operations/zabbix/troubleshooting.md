# Résolution des pannes courantes Zabbix

Guide rapide pour diagnostiquer et résoudre les incidents les plus fréquents.

### 1. Le serveur Zabbix ne démarre pas

    systemctl status zabbix-server

    journalctl -u zabbix-server -xe

**Causes fréquentes :**
**Base MariaDB non démarrée : systemctl start mariadb**
**Erreur de configuration DB : Vérifier /etc/zabbix/zabbix_server.conf**
**Port 10051 occupé : netstat -tlnp | grep 10051**

### 2. L'interface web ne répond plus (502/500)

    systemctl status apache2

    tail -f /var/log/apache2/error.log

**Solutions :**

    systemctl restart apache2
    
    Vérifier les logs PHP : /var/log/zabbix/zabbix_web.log

### 3. Les agents n'envoient plus de données

Sur l'agent :

    systemctl status zabbix-agent2

    tail -f /var/log/zabbix/zabbix_agent2.log

**Vérifications :**
**Port 10051 ouvert depuis l'agent vers le serveur**
**Certificat TLS valide**
**Hostname exact dans Zabbix**

### 4. Proxy Zabbix déconnecté

    systemctl status zabbix-proxy

    tail -f /var/log/zabbix/zabbix_proxy.log

**Vérifier :**
**Certificats dans /etc/zabbix/zabbix_ssl/**
**Configuration TLSServerCertIssuer et TLSServerCertSubject**

### 5. Base de données saturée

    mysql -u zabbix -p -e "SHOW PROCESSLIST;"

    df -h /var/lib/mysql

**Actions :**
**Purger les historiques anciens via Zabbix → Administration → Général → Housekeeper**
**Augmenter l'espace disque**

### 6. Erreur courante "Connection refused"

Vérifier les firewalls (ufw, VyOS, PfSense)

    ufw allow from 10.20.20.0/24 to any port 10051
