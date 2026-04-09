# 1. Configuration Réseau

Le poste doit être joignable et capable de résoudre les noms du domaine **ecotech.local**.

* **IP Statique** : **10.20.10.2** /29
* **Passerelle** : **10.20.10.1** (VyOS)
* **DNS** : **10.20.20.10** (AD-01)

# 2. Configuration WinRM HTTPS (Port 5986)

L'administration de l'infrastructure EcoTech repose sur un mix de protocoles standard pour la gestion de domaine et sécurisés pour les interventions d'urgence.

**Stratégie WinRM (Remote PowerShell)**

Le service WinRM a été configuré selon deux modes :

* **Mode Standard (Port 5985 - HTTP) :** Activé sur l'ensemble des serveurs du domaine pour la gestion courante. Le flux est chiffré nativement par Kerberos au sein de la forêt **ecotech.local**.
* **Mode Sécurisé (Port 5986 - HTTPS) :** Configuré spécifiquement sur le PC d'administration et les serveurs critiques pour permettre une gestion chiffrée hors domaine ou en cas de défaillance du contrôleur de domaine.

**Gestion des Certificats et HTTPS (Port 5986)**

Pour activer le listener HTTPS, des certificats auto-signés ont été générés pour chaque machine identifiée dans le plan d'adressage.

**Liste des machines configurées :**

* **ECO-BDX-GX01** (Poste Admin) : **10.20.10.2**
* **ECO-BDX-EX01** : **10.20.20.5**
* **ECO-BDX-EX02** : **10.20.20.6**
* **ECO-BDX-EX03** : **10.20.20.10**

**Commande de génération (Exemple pour EX01) :**

```powershell
# Génération du certificat auto-signé pour le chiffrement des flux
$cert = New-SelfSignedCertificate -DnsName "ECO-BDX-GX01" -CertStoreLocation "Cert:\LocalMachine\My"
```

```powershell
# Création du listener HTTPS utilisant l'empreinte du certificat généré
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $cert.Thumbprint -Force
```

```powershell
# Ajout des serveurs de l'infrastructure à la liste des hôtes de confiance
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.20.20.*" -Force
```

## 2.1. Échange de certificats et Partage SMB

Pour permettre l'authentification mutuelle sans autorité de certification (PKI), les certificats ont été exportés et échangés via des dossiers partagés créés en ligne de commande.

**Procédure d'échange :**

1. **Création du partage temporaire sur le PC Admin :**
```powershell
# Création du dossier et du partage SMB
New-Item -Path "C:\CertsExchange" -ItemType Directory
New-SmbShare -Name "Certs$" -Path "C:\CertsExchange" -FullAccess "ECOTECH\Domain Admins"
```

2. **Export et transfert (exécuté sur chaque serveur EX) :**
```powershell
# Export du certificat vers le partage du PC d'administration
Export-Certificate -Cert $cert -FilePath "\\10.20.10.2\Certs$\ECO-BDX-EX01.cer"
```

3. **Importation sur le PC d'administration :**
```powershell
# Importation dans le magasin 'Trusted People' pour autoriser la connexion
Import-Certificate -FilePath "C:\CertsExchange\ECO-BDX-EX01.cer" -CertStoreLocation "Cert:\LocalMachine\TrustedPeople"
```

## 2.2. Activation sur les serveurs cibles

Pour qu'un serveur accepte les connexions entrantes, la commande suivante a été exécutée sur chaque serveur Windows :

```powershell
# Activation du service WinRM et création des exceptions de pare-feu
Enable-PSRemoting -Force
```

## 2.3. Usage au quotidien

L'administration se fait via deux méthodes principales :

* **Session interactive** : **Enter-PSSession -ComputerName AD-01** (équivalent d'un SSH Windows).
* **Exécution de commande groupée** : **Invoke-Command -ComputerName AD-01, AD-02 -ScriptBlock { Get-Service Spooler }**.

# 3. Configuration OpenSSH Server 

**Actions réalisées :**

1. **Changement du port** : Passage du port standard **22** au port **22222** (Obscurité).
2. **Restriction de source** : Utilisation de la directive **ListenAddress** ou des fichiers **hosts.allow/deny** pour ne répondre qu'aux requêtes provenant du VLAN Admin.

```bash
# Changement du port d'écoute
Port 22222

# Restriction d'écoute à l'interface réseau du VLAN Admin (exemple pour EX-01)
ListenAddress 10.20.20.5

# Désactivation du login root direct (Sécurité renforcée)
PermitRootLogin no

# Autorisation stricte du sous-réseau d'administration (VLAN 210)
# Cette règle bloque toute tentative SSH ne provenant pas du réseau 10.20.10.0/29
AllowUsers *@10.20.10.0/29
```

**Les lignes suivantes ont été mises en commentaire à la fin du fichier sshd_config :**

```shell
# Match Group administrators
#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

*Note : Cela permet à OpenSSH d'utiliser par défaut le dossier **.ssh** dans le profil de chaque utilisateur.*

## 3.2. Modification de la configuration serveur Windows

Pour permettre l'utilisation de chemins relatifs pour les clés SSH et éviter les conflits de droits sur **ProgramData,** le fichier **C:\ProgramData\ssh\sshd_config** a été modifié.

## 3.3. Modification de la configuration serveur Linux (sshd_config)

Sur chaque serveur Linux, le fichier **/etc/ssh/sshd_config** a été modifié pour limiter la surface d'attaque.

# 4. Prise de main à distance (RDP)

```powershell
# Activation du service Bureau à distance
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
```

```powershell
# Activation de l'authentification NLA (Network Level Authentication) pour la sécurité
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
```

# 5. Outils de Diagnostic Réseau

## 5.1. Wireshark (Analyse de protocoles)

Wireshark est utilisé sur le poste d'administration pour capturer et analyser le trafic réseau en temps réel.

* **Configuration de l'interface** : Le poste utilise la carte réseau virtuelle VirtIO liée au bridge Proxmox du VLAN 210.
* **Npcap** : Installé en mode "Admin only" pour restreindre la capture de paquets aux seuls utilisateurs privilégiés.
* **Usage type** :
	* Vérification de la bonne négociation des certificats TLS lors des connexions WinRM HTTPS (Port 5986).
	* Analyse des requêtes DNS vers **AD-01** (10.20.20.10) en cas de lenteur de résolution.

## 5.2. Trippy (Diagnostic réseau combiné)

Trippy est une alternative moderne à **traceroute** et **mtr**. Il permet d'analyser les sauts (hops) entre le PC d'administration et les serveurs tout en affichant les statistiques de perte de paquets et de latence.

**Configuration de l'outil :**
Comme Trippy a été installé via Winget (Sysinternals ou binaire direct), il est accessible en ligne de commande.

```powershell
# Commande pour diagnostiquer le chemin vers un serveur en DMZ via le port SSH personnalisé
trip 10.20.30.10 -p 22222
```

**Pourquoi Trippy pour EcoTech ?**

* **Visualisation du routage** : Permet de confirmer que les paquets passent bien par la passerelle VyOS avant d'atteindre les serveurs.
* **Analyse de performance** : Utile pour détecter un goulot d'étranglement sur le lien entre les différents sites (Bordeaux, Nantes, Paris).
