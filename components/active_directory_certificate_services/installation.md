<span id="haut-de-page"></span>

# Installation — AD CS EcoTech

---

## Table des matières

- [1. Prérequis](#1-prérequis)
- [2. Installation du rôle](#2-installation-du-rôle)
- [3. Configuration du CA](#3-configuration-du-ca)
- [4. Vérification](#4-vérification)
- [5. Installation de Web Enrollment (certsrv)](#5-installation-de-web-enrollment-certsrv)

---

## 1. Prérequis

Avant de lancer l'installation, vérifier que la machine est correctement configurée.

```powershell
# Vérifier l'intégration au domaine
(Get-WmiObject Win32_ComputerSystem).Domain
# Attendu : ecotech.local

# Vérifier le nom de la machine
hostname
# Attendu : ECO-BDX-EX12

# Vérifier l'IP fixe
ipconfig
# Attendu : 10.20.20.15
```

- La machine doit obligatoirement être membre du domaine **avant** l'installation.
- Le compte utilisé doit être membre du groupe `Enterprise Admins` ou `Domain Admins`.

---

## 2. Installation du rôle

### 2.1 Lancer l'assistant

```
Démarrer - Server Manager
    - Manage
        - Add Roles and Features
```

### 2.2 Suivre l'assistant

```
Before You Begin
    - Next

Installation Type
    - Role-based or feature-based installation
    - Next

Server Selection
    - Select a server from the server pool
        - Sélectionner ECO-BDX-EX12
    - Next

Server Roles
    - Cocher : Active Directory Certificate Services
        - Pop-up : Add Features
    - Next

Features
    - Ne rien modifier
    - Next

AD CS
    - Next

Role Services
    - Cocher uniquement : Certification Authority
    - Next

Confirmation
    - Install
```

- Ne pas fermer la fenêtre à la fin de l'installation.
- Cliquer sur le lien bleu **"Configure Active Directory Certificate Services"** qui apparaît une fois l'installation terminée.

---

## 3. Configuration du CA

### 3.1 Suivre l'assistant de configuration

```
Credentials
    - Vérifier : ECOTECH\Administrator
    - Next

Role Services
    - Cocher : Certification Authority
    - Next

Setup Type
    - Enterprise CA
    - Next
```

- Enterprise CA requiert que la machine soit membre du domaine.
- C'est ce type qui permet l'intégration native avec Active Directory.

```
CA Type
    - Root CA
    - Next

Private Key
    - Create a new private key
    - Next

Cryptography
    - Cryptographic provider : RSA#Microsoft Software Key Storage Provider
    - Key length : 4096
    - Hash algorithm : SHA256
    - Next

CA Name
    - Common name : ecotech-ECO-BDX-EX12-CA
    - Distinguished name suffix : DC=ecotech,DC=local (automatique)
    - Next

Validity Period
    - 10 Years
    - Next

Certificate Database
    - Laisser les chemins par défaut
        C:\Windows\system32\CertLog
    - Next

Confirmation
    - Vérifier le récapitulatif :
        CA Type    : Enterprise Root
        Algorithme : SHA256
        Clé        : 4096 bits
        Validité   : 10 ans
        DN         : CN=ecotech-ECO-BDX-EX12-CA,DC=ecotech,DC=local
    - Configure
```

---

## 4. Vérification

### 4.1 Vérifier que le service CA tourne

```powershell
Get-Service CertSvc
# Attendu : Status Running
```

### 4.2 Ouvrir la console de gestion

```
Démarrer - Certification Authority (certsrv.msc)
    - ecotech-ECO-BDX-EX12-CA doit apparaître
```

### 4.3 Vérifier le déploiement automatique sur le domaine

- Sur un **poste client du domaine** :

```powershell
gpupdate /force

# Vérifier que le CA est bien présent dans le magasin de confiance
certutil -store "Root" | findstr "ecotech-ECO-BDX-EX12-CA"
# Doit retourner le nom du CA
```

---

## 5. Installation de Web Enrollment (certsrv)

- `certsrv` est l'interface web d'AD CS. Elle permet de soumettre des CSR et de télécharger les certificats signés depuis un navigateur sans ligne de commande.
- Elle nécessite IIS qui est installé automatiquement avec le rôle.

### 5.1 Installer le rôle

```
Server Manager
    - Manage - Add Roles and Features
        - Next - Next - Next
            - Server Roles
                - Active Directory Certificate Services
                    - Déplier le rôle
                        - Cocher : Certification Authority Web Enrollment
                            - Add Features (popup)
                                - Next - Install
```

### 5.2 Activer ASP

- Nécessaire car certsrv est une application ASP classique.

```powershell
Install-WindowsFeature Web-ASP
iisreset
```

### 5.3 Corriger l'authentification dans IIS

- Par défaut IIS active Anonymous Authentication et Windows Authentication en même temps, ce qui provoque une erreur 403. Il faut désactiver l'authentification anonyme.

```
IIS Manager
    - Sites - Default Web Site - CertSrv
        - Authentication
            - Clic droit sur "Anonymous Authentication"
                - Disable
            - Windows Authentication doit rester Enabled
```

```powershell
iisreset
```

### 5.4 Vérification

- Depuis un **poste client du domaine** :

```
http://10.20.20.15/certsrv
    - Page "Microsoft Active Directory Certificate Services
      — ecotech-ECO-BDX-EX12-CA"
```

<p align="right">
  <a href="#haut-de-page">Retour au début de la page</a>
</p>