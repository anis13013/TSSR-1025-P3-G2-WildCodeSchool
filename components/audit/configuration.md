# Installation de l'outils PingCastle sur ECO-BDX-EX02

- Dans ce document sera expliqué les étapes pour corriger les vulnérabilités détéctées suite à l'audit de sécurité.
- De préference les ajustement seront fait dans l'ordre de priorité via GPO, sinon via PowerShell et pour finir via Interface Graphique.

---

## Table des matières 

- [1. Désactivation du service Print Spooler sur les DCs](#1-désactivation-du-service-print-spooler-sur-les-dcs)
  - [Résultat](#résultat)
- [2. Déploiement de Windows LAPS (GPO)](#2-déploiement-de-windows-laps-gpo)
  - [Résultat](#résultat-1)
- [3. Politique de mot de passe insuffisante (AD AC)](#3-politique-de-mot-de-passe-insuffisante-ad-ac)
  - [Résultat](#résultat-2)
- [4. Comptes administrateurs sensibles et non délégables (GUI)](#4-comptes-administrateurs-sensibles-et-non-délégables-gui)
  - [Résultat](#résultat-3)
- [5. Groupe Schema Admins non vide (GUI)](#5-groupe-schema-admins-non-vide-gui)
  - [Résultat](#résultat-4)
- [6. Désactivation des protocoles NTLMv1 et LM (GPO)](#6-désactivation-des-protocoles-ntlmv1-et-lm-gpo)
  - [Résultat](#résultat-5)
- [7. Restriction de l'enregistrement des ordinateurs dans le domaine (PowerShell)](#7-restriction-de-lenregistrement-des-ordinateurs-dans-le-domaine-powershell)
  - [Résultat](#résultat-6)

---

## 1. Désactivation du service Print Spooler sur les DCs

---

### Description de la faille

Le service **Print Spooler** est un service Windows qui gère les travaux d'impression.
Lorsqu'il est actif sur un contrôleur de domaine, il expose le serveur à la vulnérabilité **PrintNightmare (CVE-2021-34527)**.

Cette faille permet à un attaquant d'effectuer une élévation de privilèges jusqu'au niveau **SYSTEM** sur le DC, ce qui représente une compromission totale du domaine.

Un contrôleur de domaine ne devant pas gérer d'impression, ce service doit être désactivé.

---

### Correction

La correction a été appliquée via une GPO liée à l'OU **Domain Controllers**.

**Nom de la GPO :** `CR-DC-01-DisablePrintSpooler-v1.0`

---

### Etape 1 - Création de la GPO

```
- Ouvrir la console GPMC (gpmc.msc)
- Se positionner sur l'OU Domain Controllers
- Clic droit - "Create a GPO in this domain and link it here"
- Nommer la GPO : CR-DC-01-DisablePrintSpooler-v1.0
```

### Etape 2 - Configuration de la GPO

```
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Windows Settings
    - Security Settings
      - System Services
        - Print Spooler
          - Cocher "Define this policy setting"
          - Sélectionner "Disabled"
```

### Etape 3 - Security Filtering

```
- Onglet Scope de la GPO
- Section Security Filtering
- Supprimer les entrées existantes
- Ajouter le groupe "Domain Controllers"
```

### Etape 4 - Application et vérification

```
- Lancer gpupdate /force sur les DCs concernés
- Vérifier le statut du service avec la commande suivante :

Get-Service -Name Spooler
```

**Résultat attendu :**

```
Status     Name       DisplayName
------     ----       -----------
Stopped    Spooler    Print Spooler
```

---

### Résultat

| Elément | Avant | Après |
| --- | --- | --- |
| Statut du service Spooler | Running | Stopped |
| GPO appliquée | Non | Oui |
| Vulnérabilité PrintNightmare | Exposé | Corrigé |

---

## 2. Déploiement de Windows LAPS (GPO)

---

### Description de la faille

Sans LAPS, le compte **Administrateur local** de chaque machine du domaine partage généralement le même mot de passe.
Si un attaquant compromet une machine, il peut utiliser ce mot de passe pour se connecter en administrateur local sur toutes les autres machines du domaine.

**Windows LAPS** (Local Administrator Password Solution) résout ce problème en générant automatiquement un mot de passe unique par machine, en le stockant chiffré dans l'AD et en le renouvelant à intervalles réguliers.

---

### Correction

### Etape 1 - Extension du schéma AD

A effectuer une seule fois sur le domaine depuis le DC détenant le rôle **Schema Master**.

```
- Vérifier quel DC détient le rôle Schema Master :
  netdom query fsmo

- Etendre le schéma AD pour Windows LAPS :
  Update-LapsADSchema
```

**Vérification :**

```
Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter {name -like "ms-LAPS*"}
```

Les attributs suivants doivent apparaitre :

```
ms-LAPS-EncryptedDSRMPassword
ms-LAPS-EncryptedDSRMPasswordHistory
ms-LAPS-EncryptedPassword
ms-LAPS-EncryptedPasswordHistory
ms-LAPS-Password
ms-LAPS-PasswordExpirationTime
```

---

### Etape 2 - Délégation des permissions sur les OUs

Chaque machine doit avoir le droit d'écrire son propre mot de passe dans l'AD.
La commande suivante est à répéter sur chaque OU contenant des machines :

```
Set-LapsADComputerSelfPermission -Identity "OU=XX,OU=XX,DC=ecotech,DC=local"
```

---

### Etape 3 - Configuration de la GPO LAPS

**Nom de la GPO :** `CR-BDX-001-LAPS-v1.0`

```
- Ouvrir la console GPMC (gpmc.msc)
- Lier la GPO à l'OU contenant les machines
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Policies
    - Administrative Templates
      - System
        - LAPS
```

**Parametre 1 - Configure password backup directory**

```
- Enabled
- Backup directory : Active Directory
```

**Parametre 2 - Password Settings**

```
- Enabled
- Password complexity : Large letters + small letters + numbers + special characters
- Password length : 14
- Password age (days) : 30
```

**Parametre 3 - Enable password encryption**

```
- Enabled
```

---

### Etape 4 - Application et vérification

```
- Lancer gpupdate /force sur les machines cibles
- Vérifier la génération du mot de passe depuis un DC :

  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
```

**Résultat attendu :**

```
ComputerName     : NOM-DE-LA-MACHINE
Account          : Administrateur
Password         : xxxxxxxxxxxxxxx
Source           : EncryptedPassword
DecryptionStatus : Success
AuthorizedDecryptor : ECOTECH\Domain Admins
```

---

### Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Mot de passe admin local | Identique sur toutes les machines | Unique par machine |
| Stockage du mot de passe | Non géré | Chiffré dans l'AD |
| Renouvellement | Manuel | Automatique tous les 30 jours |
| Accès au mot de passe | Non contrôlé | Réservé aux Domain Admins |

---

## 3. Politique de mot de passe insuffisante (AD AC)

---

### Description de la faille

PingCastle a détecté qu'une politique de mot de passe autorisait des mots de passe de moins de 8 caractères sur le domaine.
Un mot de passe trop court est vulnérable aux attaques par force brute et par dictionnaire.

La correction a été appliquée via une **Fine-Grained Password Policy** (PSO) qui prend le dessus sur la Default Domain Policy et s'applique directement à des groupes d'utilisateurs.

---

### Correction

### Etape 1 - Création de la PSO via l'ADAC

```
- Ouvrir l'ADAC (dsac.exe)
- Naviguer vers ecotech
  - System
    - Password Settings Container
      - Clic droit - New - Password Settings
```

### Etape 2 - Configuration des paramètres

**Paramètres généraux**

```
Name       : PasswordPolicy
Precedence : 1
```

**Complexité et longueur**

```
- Enforce minimum password length : 14 caractères
- Enforce password history        : 24 mots de passe
- Password must meet complexity requirements : Oui
```

**Expiration**

```
- Enforce minimum password age : 1 jour
- Enforce maximum password age : 90 jours
```

**Verrouillage de compte**

```
- Enforce account lockout policy          : Oui
- Number of failed logon attempts         : 3
- Reset failed logon attempts count after : 5 minutes
- Account will be locked out              : 5 minutes
```

### Etape 3 - Application aux groupes

Dans la section **Directly Applies To** :

```
- Cliquer sur Add
- Ajouter les groupes contenant les utilisateurs du domaine
```

Groupes appliqués :

```
- ECO-BDX-GX-GXS
- ECO-BDX-UX
- STU-NTE-UX
- UBI-PAR-UX
```

### Etape 4 - Vérification

```powershell
Get-ADFineGrainedPasswordPolicy -Filter {Name -like "*"} | Select-Object Name, MinPasswordLength, ComplexityEnabled
```

**Résultat attendu :**

```
Name           MinPasswordLength  ComplexityEnabled
----           -----------------  -----------------
PasswordPolicy        14               True
```

---

### Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Longueur minimale | Inférieure à 8 caractères | 14 caractères |
| Complexité | Non appliquée | Obligatoire |
| Historique | Non configuré | 24 mots de passe |
| Verrouillage | Non configuré | 3 tentatives - 5 minutes |

---

## 4. Comptes administrateurs sensibles et non délégables (GUI)

---

### Description de la faille

Sans le flag **"Ce compte est sensible et ne peut pas être délégué"**, un compte administrateur peut être usurpé via la délégation Kerberos.
Un attaquant exploitant cette faille peut se faire passer pour un administrateur depuis un compte de service compromis.

PingCastle a identifié 5 comptes concernés :

```
GX-Romain Genoud
GX-Frederick Flavil
GX-Anis Boutaleb
GX-Nicolas Jouveaux
Administrateur
```

---

### Correction

Le flag a été activé manuellement sur chaque compte via la console **Active Directory Users and Computers** (ADUC).

```
- Ouvrir ADUC (dsa.msc)
- Localiser le compte administrateur
- Clic droit - Properties
- Onglet Account
- Cocher "Account is sensitive and cannot be delegated"
- OK
```

Cette opération a été répétée sur chacun des 5 comptes listés ci-dessus.

---

### Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Comptes sans flag de délégation | 5 | 0 |
| Risque d'usurpation via délégation Kerberos | Présent | Corrigé |

---

## 5. Groupe Schema Admins non vide (GUI)

---

### Description de la faille

Le groupe **Schema Admins** donne les droits de modification du schéma Active Directory.
C'est l'un des groupes les plus privilégiés du domaine car une modification du schéma est irréversible et impacte l'ensemble de la forêt.

Ce groupe doit être **vide en permanence** et ne se remplir que ponctuellement lors d'opérations de modification du schéma.

PingCastle a détecté la présence du compte **Administrateur** dans ce groupe.

---

### Correction

Le compte Administrateur a été retiré manuellement du groupe via la console **Active Directory Users and Computers**.

```
- Ouvrir ADUC (dsa.msc)
- Naviguer vers Builtin ou Users
- Localiser le groupe Schema Admins
- Clic droit - Properties
- Onglet Members
- Sélectionner le compte Administrateur
- Cliquer sur Remove
- OK
```

---

### Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Membres dans Schema Admins | 1 (Administrateur) | 0 |
| Risque de modification du schéma | Présent | Corrigé |

---

## 6. Désactivation des protocoles NTLMv1 et LM (GPO)

---

### Description de la faille

Les protocoles d'authentification **LM (LAN Manager)** et **NTLMv1** sont des protocoles obsolètes et vulnérables.
Ils permettent à un attaquant d'intercepter et de cracker les hash d'authentification via des attaques de type **Pass-the-Hash** ou **brute force**.

PingCastle a détecté que ces protocoles étaient encore autorisés sur le domaine, ce qui représente +15 points sur le score Stale Objects.

---

### Correction

La correction a été appliquée via une GPO liée à l'OU **Domain Controllers**.

**Nom de la GPO :** `CR-G-002-DisableNTLMv1-v1.0`

```
- Ouvrir la console GPMC (gpmc.msc)
- Créer une nouvelle GPO liée à l'OU Domain Controllers
- Nom : CR-G-002-DisableNTLMv1-v1.0
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Policies
    - Windows Settings
      - Security Settings
        - Local Policies
          - Security Options
            - Network security : LAN Manager Authentication Level
              - Valeur : Send NTLMv2 response only. Refuse LM and NTLM
```

---

### Valeurs de référence

| Valeur | Description |
| --- | --- |
| 0 | Envoie LM et NTLM |
| 1 | Envoie LM et NTLM, utilise NTLMv2 si négocié |
| 2 | Envoie NTLM uniquement |
| 3 | Envoie NTLMv2 uniquement |
| 4 | Envoie NTLMv2, refuse LM |
| **5** | **Envoie NTLMv2, refuse LM et NTLM - valeur appliquée** |

---

### Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Protocole LM autorisé | Oui | Non |
| Protocole NTLMv1 autorisé | Oui | Non |
| Niveau d'authentification | 0 | 5 |
| GPO appliquée | Non | Oui |

---

## 7. Restriction de l'enregistrement des ordinateurs dans le domaine (PowerShell)

---

### Description de la faille

Par défaut dans l'Active Directory, l'attribut **ms-DS-MachineAccountQuota** est défini à 10.
Cela signifie que n'importe quel utilisateur standard peut joindre jusqu'à 10 machines au domaine sans droits administrateur.

Cette configuration représente un risque car des machines non maîtrisées peuvent apparaître sur le réseau sans contrôle de l'équipe IT.

---

### Correction

La valeur de l'attribut **ms-DS-MachineAccountQuota** a été modifiée à 0 directement sur l'objet racine du domaine.

```powershell
Set-ADDomain -Identity "ecotech.local" -Replace @{"ms-DS-MachineAccountQuota"="0"}
```

Seuls les membres des groupes suivants peuvent désormais joindre des machines au domaine :

```
- Domain Admins
- Enterprise Admins
- Administrateur du domaine
```

### Vérification

```powershell
Get-ADDomain -Identity "ecotech.local" | Select-Object -ExpandProperty DistinguishedName | ForEach-Object { Get-ADObject -Identity $_ -Properties ms-DS-MachineAccountQuota | Select-Object ms-DS-MachineAccountQuota }
```

**Résultat attendu :**

```
ms-DS-MachineAccountQuota
-------------------------
            0
```

---

### Résultat

| Element | Avant | Après |
| --- | --- | --- |
| Valeur ms-DS-MachineAccountQuota | 10 | 0 |
| Utilisateurs pouvant joindre des machines | Tous | Administrateurs uniquement |
