# Guide de débogage rsyslog & NXLog

Ce document regroupe les commandes, techniques et astuces les plus utiles pour diagnostiquer les problèmes de **rsyslog** (serveur central ou client) et **NXLog** (Windows).

## Sommaire

- [1. Vérifications de base rapides](#1-vérifications-de-base-rapides)
- [2. Vérifier la syntaxe et la configuration consolidée](#2-vérifier-la-syntaxe-et-la-configuration-consolidée)
- [3. Problèmes courants et leurs solutions](#3-problèmes-courants-et-leurs-solutions)
- [4. Débogage côté NXLog (Windows)](#4-débogage-côté-nxlog-windows)
- [5. Tests manuels et génération de logs](#5-tests-manuels-et-génération-de-logs)
- [6. Outils complémentaires](#6-outils-complémentaires)

---

### 1. Vérifications de base rapides

#### Vérifier si le service est démarré
```bash
systemctl status rsyslog
```

#### Vérifier l'écoute sur le port 514
```bash
ss -tuln | grep 514
```

#### Derniers logs rsyslog lui-même
```bash
journalctl -u rsyslog -n 100 -f
tail -n 50 /var/log/syslog | grep rsyslog
```

#### Version (la plus récente possible)
```bash
rsyslogd -v
```

### 2. Vérifier la syntaxe et la configuration

**C’est la première chose à faire quand une règle ne s’applique pas.**

#### Vérification syntaxe simple (exit code 0 = OK)
```bash
rsyslogd -N1
```

#### Afficher la config telle que rsyslog la voit vraiment
```bash
rsyslogd -N1 -o /tmp/rsyslog-consolidated.conf
```

#### Regarder le résultat
less /tmp/rsyslog-consolidated.conf
→ Cherche les typos classiques : imtcp → imptcp, input(type="imtcp") mal formé, etc.

### 3. Problèmes courants et leurs solutions

|Problème                            |Symptôme/Log                       |Solution rapide                                                         |
|------------------------------------|-----------------------------------|------------------------------------------------------------------------|
|**Pas de réception TCP 514**        |**ss -tuln ne montre pas 514**     |**Vérifie module(load="imtcp") + input(type="imtcp" port="514")**       |
|**Logs distants ignorés**           |**Rien dans /var/log/remote/**     |**Vérifie règle if $fromhost-ip != '127.0.0.1' ... et ordre des règles**|
|**Duplication dans /var/log/syslog**|**Logs distants aussi dans syslog**|**Ajoute & stop après l’action omfile**                                 |
|**File d’attente qui explose**      |**"queue full", perte de messages**|**Augmente Queue.Size="50000" ou active disque Queue.FileName="...**    |
|**Forwarding ne part pas**          |**Rien reçu côté serveur**         |**Vérifie firewall client/serveur + protocol="tcp" + template IETF**    |
|**Permission sur /var/log/remote**  |**"permission denied" dans debug** |**chown syslog:adm /var/log/remote ; chmod 750**                        |
|**Trop de fichiers ouverts**        |**Arrêt après ~1024 descripteurs** |**Augmente ulimit -n 4096 pour rsyslog ou utilise omfile avec dynafile**|

### 4. Débogage côté NXLog (Windows)

#### Vérifier le statut du service
```PowerShell
Get-Service nxlog
```

#### Voir les logs NXLog (par défaut)
```PowerShell
Get-Content "C:\Program Files\nxlog\data\nxlog.log" -Tail 100 -Wait
```

#### Redémarrer
```PowerShell
Restart-Service nxlog
```

#### Test rapide depuis PowerShell
```PowerShell
Write-EventLog -LogName Application -Source "Application" -EventID 777 -EntryType Information -Message "NXLog debug test $(Get-Date)"
```

**Chercher dans nxlog.log des lignes comme :**

ERROR → connexion refusée, certificat TLS, etc.
WARNING → parsing syslog qui échoue

### 5. Tests manuels et génération de logs

**Debian / Linux :**
```bash
logger -p local0.debug   "DEBUG test local0 - $(hostname) - $(date)"
logger -p user.info      "INFO test forwarding - should appear remotely"
logger -t MyApp          "Tagged test - MyApp"
```

**Windows (PowerShell admin) :**
```PowerShell
Write-EventLog -LogName Application -Source "Application" -EventId 999 -EntryType Warning -Message "TEST WARNING Windows forwarding"
```

**Sur le serveur central :**

#### Lister tous les hôtes reçus
```bash
ls -l /var/log/remote/
```

#### Suivi live d’un hôte précis
tail -f /var/log/remote/*/NOM-DE-LA-MACHINE*.log

### 6. Outils complémentaires
```bash
tcpdump -i any port 514 -nn -vv # pour voir le trafic syslog
wireshark # filtre syslog
rsyslogd -v # liste modules chargés
