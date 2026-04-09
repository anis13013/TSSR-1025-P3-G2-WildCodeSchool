<span id="haut-de-page"></span>
# Active Directory Domain Services
---
## Table des matières

- [1. Rôle du service](#1-rôle-du-service)
- [2. Position dans l'architecture](#2-position-dans-larchitecture)
- [3. Prérequis](#3-prérequis)
- [4. Fonctionnalités](#4-fonctionnalités)
- [5. Documentation liée](#5-documentation-liée)

## 1. Rôle du service  
Active Directory est le cœur de l'authentification et de la gestion centralisée des identités et des ressources de l'entreprise.  

Il fournit :
- Authentification des utilisateurs et ordinateurs.
- Gestion des comptes, groupes, mots de passe.
- Politiques de sécurité (GPO – Group Policy Objects).
- Résolution de noms interne (DNS intégré).
- Base de référence pour la plupart des services (VoIP, fichiers, VPN, messagerie, endpoint protection, etc.).
  
## 2. Position dans l'architecture  
- Serveurs : SRV-AD-01 (172.16.100.2) VLAN_100 et SRV-AD-02 (172.16.X.X) VLAN_X avec IP statique.    
- Redondance : 2 contrôleurs de domaine.  
- Site AD : un seul site principal (Bordeaux) pour l'instant – possibilité d'ajouter des sites distants plus tard.
  
## 3. Prérequis 
- Windows Server 2022.  
- Au moins 8 vCPU / 32–64 Go RAM par DC physique ou virtuel.  
- Stockage : 2 × SSD RAID1 minimum (OS) + espace pour la base NTDS (~10–20 Go selon taille).  
- DNS intégré.  
- NTP synchronisé.
- Firewall : ports AD ouverts entre DCs et clients (voir matrice flux)

## 4. Fonctionnalités  
- Domaine : ecotech.local
- Niveau fonctionnel du domaine/forêt : Windows Server 2022.  
- Groupes de sécurité :  
  - Globaux : par département.   
  - Universels : pour accès transversaux.  
- GPO principales :  
  - GPO_Sécurité_Base (mot de passe, verrouillage, Windows Update…)  
  - GPO_Départements (par OU – ex : blocage USB Finance/DRH)  
  - GPO_VoIP (QoS, provisioning téléphone)  
  - GPO_Endpoint_Protection (intégration Defender)  
- Certificats internes : AD CS (Certificate Services) prévu pour VPN, WiFi 802.1X, LDAPS  

## 5. Documentation liée

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
