# Guide de configuration – rsyslog (serveur central) & NXLog (Windows)
**Serveur central de logs** : ECO-BDX-EX04 – 10.20.20.18 (VLAN 220)    
**Port utilisé** : 514/TCP

---

## Sommaire

1. [Configuration du serveur central rsyslog](#1-configuration-du-serveur-central-rsyslog)
   - 1.1 [Activation de la réception TCP](#11-activation-de-la-réception-tcp)
   - 1.2 [Template de stockage par hostname + date](#12-template-de-stockage-par-hostname--date)
   - 1.3 [Règles de stockage des logs distants](#13-règles-de-stockage-des-logs-distants)
   - 1.4 [Création du répertoire de stockage](#14-création-du-répertoire-de-stockage)
   - 1.5 [Redémarrage et vérification](#15-redémarrage-et-vérification)
2. [Configuration des serveurs Debian (forwarding)](#2-configuration-des-serveurs-debian-forwarding)
3. [Configuration des machines Windows (NXLog)](#3-configuration-des-machines-windows-nxlog)
4. [Tests rapides](#4-tests-rapides)

---

## 1. Configuration du serveur central rsyslog
### 1.1 Activation de la réception TCP
**Editer le fichier :**
```bash
nano /etc/rsyslog.d/10-server.conf
```
**Et y ajouter cette partie :**
```text
module(load="imtcp")
input(type="imtcp" port="514")
```
### 1.2 Template de stockage par hostname + date
```bash
nano /etc/rsyslog.d/20-templates.conf
```
**Contenu :**
```text
template(name="RemoteHostDaily"
         type="string"
         string="/var/log/remote/%hostname%/%$year%-%$month%-%$day%.log")
```
### 1.3 Règles de stockage des logs distants
```bash
nano /etc/rsyslog.d/30-remote.conf
```
**Contenu :**
```text
# Ignorer logs locaux
if $fromhost-ip == '127.0.0.1' or $fromhost-ip == '::1' then stop
# Stocker logs distants
*.* action(type="omfile" dynaFile="RemoteHostDaily")
# Ne pas dupliquer dans syslog/messages
& stop
```
### 1.4 Création du répertoire de stockage
```bash
mkdir -p /var/log/remote
chown syslog:adm /var/log/remote
chmod 750 /var/log/remote
```
### 1.5 Redémarrage et vérification
```bash
systemctl restart rsyslog
systemctl status rsyslog
ss -tuln | grep 514
```
## 2. Configuration des serveurs Debian (forwarding)
Sur chaque serveur Debian :
```bash
nano /etc/rsyslog.d/99-forward-central.conf
```
**Contenu :**
```text
*.* action(type="omfwd"
         target="10.20.20.18"
         port="514"
         protocol="tcp"
         template="RSYSLOG_SyslogProtocol23Format"
         Queue.Type="LinkedList"
         Queue.Size="10000"
         Action.ResumeRetryCount="-1")
```
**Appliquer :**
```bash
systemctl restart rsyslog
```
## 3. Configuration des machines Windows (NXLog)
**Éditer :** C:\Program Files\nxlog\conf\nxlog.conf
**Contenu minimal :**
```text
<Input eventlog>
    Module  im_msvistalog
</Input>
<Extension syslog>
    Module      xm_syslog
</Extension>
<Output central>
    Module      om_tcp
    Host        10.20.20.18
    Port        514
    Exec        to_syslog_ietf();
</Output>
<Route 1>
    Path        eventlog -> central
</Route>
```
**Redémarrer le service :**
```cmd
net stop nxlog
net start nxlog
```
ou via services.msc
## 4. Tests rapides
Depuis un serveur Debian :
```bash
logger -p local0.info "TEST CONFIG - Debian - $(hostname) - $(date)"
```
Depuis Windows (PowerShell admin) :
```PowerShell
Write-EventLog -LogName Application -Source "Application" -EventId 777 -EntryType Information -Message "TEST CONFIG - Windows - $env:COMPUTERNAME - $(Get-Date)"
```
Sur ECO-BDX-EX04 (vérification) :
```bash
ls -l /var/log/remote/
tail -f /var/log/remote/G2-ECO-BDX-EX04/*.log
```
