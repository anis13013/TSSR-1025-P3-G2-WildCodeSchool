# Guide d’installation – rsyslog (serveur central) & NXLog (Windows)

## 1. Serveur central de logs (Debian 12) – ECO-BDX-EX04

### 1.1 Connexion en root

```bash
su -
```

### 1.2 Mise à jour complète du système

```bash
apt update && apt full-upgrade -y
```

### 1.3 Installation des paquets utiles
```bash
apt install -y curl wget gnupg nano btop htop less fail2ban rsyslog
```

### 1.4 Configuration du nom d’hôte
```bash
hostnamectl set-hostname ECO-BDX-EX04

# Vérifier le fichier hosts

nano /etc/hosts
```

**Contenu attendu :**

```text
127.0.0.1   localhost
10.20.20.18 ECO-BDX-EX04
```

**Appliquer le changement :**
```bash
systemctl restart systemd-hostnamed
```

### 1.5 Activation et démarrage de rsyslog
```bash
systemctl enable rsyslog
systemctl start rsyslog
systemctl status rsyslog
```

---

## 2. Tous les serveurs Debian (forwarding vers le central)

### 2.1 Mise à jour et installation rsyslog
```bash
apt update && apt install -y rsyslog
```

### 2.2 Activation du service
```bash
systemctl enable rsyslog
systemctl start rsyslog
systemctl status rsyslog
```

---

## 3. Machines Windows (serveurs et postes clients)

### 3.1 Téléchargement et installation de NXLog

Aller sur : https://nxlog.co/products/nxlog-community-edition/download

Télécharger la version Community Edition pour Windows

Exécuter l’installateur → installation par défaut suffit

Accepter les termes et terminer l’installation

### 3.2 Vérification de l’installation

Ouvrir une invite de commandes en mode administrateur :

```cmd
sc query nxlog
```

→ Vous devriez voir STATE = 4 RUNNING si le service est démarré.

Ou via PowerShell :

```powershell
PowerShellGet-Service nxlog
```
