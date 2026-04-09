# 1. Prérequis et Environnement de déploiement

Le PC d'administration est la pierre angulaire de la gestion de l'infrastructure **EcoTech Solutions**. Il est déployé en tant que machine virtuelle (VM) sur l'hyperviseur Proxmox VE.

## 1.1. Caractéristiques matérielles (VM Proxmox)

| Ressource | Spécification | Justification |
| --- | --- | --- |
| **Processeur (vCPU)** | 2 Cores (Type : Host) | Fluidité de l'interface et des outils d'analyse (Wireshark). |
| **Mémoire (RAM)** | **8 Go** | Supporte le multitâche (RSAT + Navigateur + Terminaux SSH). |
| **Stockage (Disque)** | **20 Go** (VirtIO Block) | Suffisant pour l'OS et les outils d'administration sans données locales. |
| **Carte Réseau** | 1 interface (VirtIO) | Connectée au bridge correspondant au **VLAN 210** (Admin). |
| **BIOS/EFI** | OVMF (UEFI) | Requis pour le support complet de Windows 11 et Secure Boot. |

## 1.2. Prérequis Logiciels

* **Système d'Exploitation :** Windows 11 Professionnel (Version 22H2 ou supérieure).
* *Note : La version Pro est indispensable pour la jonction au domaine **ecotech.local** et l'installation des outils RSAT.*
* **Sécurité :** Agent TPM 2.0 virtuel activé sur Proxmox pour répondre aux exigences de Windows 11.

# 2. Déploiement des outils d'administration Windows

L'installation des outils doit être réalisée **après la jonction au domaine** et depuis une session **Administrateur du Domaine**. L'utilisation du paramètre **--scope machine** est impérative pour garantir que les outils soient disponibles pour tous les administrateurs se connectant sur ce poste.

## 2.1. Prérequis : Jonction au domaine et session

Avant toute installation logicielle, le poste doit être intégré à l'annuaire centralisé :

1. **DNS** : Configurer l'interface réseau pour pointer vers **10.20.20.5** (AD-01).
2. **Jonction** : Joindre le domaine **ecotech.local**.
3. **Connexion** : Redémarrer et ouvrir une session avec un compte membre du groupe "Domain Admins".

# 2.2. Installation des outils Rsat

```powershell
# Installation des outils Active Directory (Console Utilisateurs et ordinateurs AD, Domaines et approbations)
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

```powershell
# Installation de la console de gestion des stratégies de groupe (GPMC)
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
```

```powershell
# Installation de la console de gestion DNS
Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
```

```powershell
# Installation de la console DHCP (nécessaire pour gérer le failover AD-01/AD-02)
Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
```

```powershell
# Affiche la liste des outils RSAT désormais présents sur le poste
Get-WindowsCapability -Online | Where-Object {($_.Name -like "Rsat*") -and ($_.State -eq "Installed")} | Select-Object Name, State
```

## 2.3. Installation de la suite Sysinternals

La suite **Microsoft Sysinternals** est utilisée pour le dépannage avancé du système et l'analyse des processus.

* **Méthode recommandée** : Installation via l'utilitaire de gestion de paquets Windows (**Winget**) pour faciliter les mises à jour futures.
* **Commande d'installation** :

```powershell
# Installation silencieuse de l'ensemble des outils (Process Explorer, TcpView, PsExec, etc.)
winget install -e --id Microsoft.Sysinternals.Suite --scope machine --accept-package-agreements
```

* **Outils clés utilisés pour l'administration EcoTech** :
* **Process Explorer** : Surveillance détaillée de l'utilisation des ressources.
* **Autoruns** : Gestion des services et programmes au démarrage.
* **PsExec** : Exécution de commandes à distance sur les serveurs de l'infrastructure.
* **TCPView** : Visualisation en temps réel des connexions réseau actives sur le poste.

### Pourquoi ces manipulations sont-elles obligatoires ?

* **Le registre (EulaAccepted)** : Sans cela, si un administrateur lance un script qui utilise **PsExec** en arrière-plan, le script restera bloqué indéfiniment en attendant que quelqu'un clique sur "Accept" dans une fenêtre invisible.
* **Le PATH** : En administration, on ne veut pas naviguer dans **C:\Program Files\...** à chaque diagnostic. Taper **tcpview** dans un terminal doit ouvrir l'outil instantanément pour analyser un flux suspect vers le VLAN 220.
# 3. Installation des outils tiers via Winget

L'utilisation de **--scope machine** est systématique pour permettre à tous les administrateurs du domaine de retrouver les outils sur leur session.

**Suite de diagnostic système**

```powershell
winget install --id Microsoft.Sysinternals --scope machine --accept-package-agreements
```

**Gestionnaires de connexions et transferts**

```powershell
winget install --id Mobatek.MobaXterm --scope machine --accept-package-agreements
```

```powershell
winget install --id SimonTatham.PuTTY --scope machine --accept-package-agreements
```

```powershell
winget install --id WinSCP.WinSCP --scope machine --accept-package-agreements
```

**Analyse réseau et versioning**

```powershell
winget install --id Wireshark.Wireshark --scope machine --accept-package-agreements
```

```powershell
winget install --id Trippy.Trippy --scope machine --accept-package-agreements
```

```powershell
winget install --id Git.Git --scope machine --accept-package-agreements
```
