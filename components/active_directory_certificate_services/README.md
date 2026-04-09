<span id="haut-de-page"></span>
# Autorité de Certification — AD CS EcoTech

---

## Table des matières

- [1. Rôle du service](#1-rôle-du-service)
- [2. Position dans l'architecture](#2-position-dans-larchitecture)
- [3. Prérequis](#3-prérequis)
- [4. Services certifiés](#4-services-certifiés)

---

## 1. Rôle du service

L'Autorité de Certification interne EcoTech est le service central de gestion des certificats numériques de l'infrastructure. Elle permet de signer et distribuer des certificats valides pour tous les services internes sans dépendre d'une CA publique externe.

Elle fournit :
- Signature de certificats pour les services internes (HTTPS, SMTP, IMAP...).
- Chaîne de confiance reconnue par toutes les machines du domaine.
- Déploiement automatique du certificat racine via Active Directory.
- Suppression des alertes de sécurité navigateur sur les services internes.
- Traçabilité complète des certificats émis, révoqués et expirés.

---

## 2. Position dans l'architecture

- **Serveur** : ECO-BDX-EX12 avec IP statique `10.20.20.15/27`.
- **VLAN** : VLAN Serveurs — segment réseau interne.
- **Passerelle** : `10.20.20.1`.
- **DNS** : `10.20.20.5` — Contrôleur de domaine principal.
- **Domaine** : `ecotech.local`.
- **Type de CA** : Enterprise Root CA — intégrée à Active Directory.
- **Nom du CA** : `ecotech-ECO-BDX-EX12-CA`.

---

## 3. Prérequis

- **Système** : Windows Server 2022 — interface graphique (GUI).
- **Domaine** : Machine membre du domaine `ecotech.local`.
- **IP fixe** : `10.20.20.15` configurée avant installation.
- **DNS** : Résolution `ecotech.local` fonctionnelle depuis la machine.
- **Pare-feu** :
  - Règles autorisant les machines du domaine vers ECO-BDX-EX12 (HTTPS 443)
  - Règles autorisant ECO-BDX-EX12 vers Contrôleurs de domaine (LDAP 389, LDAPS 636)

---

## 4. Services certifiés

| Service | CN |
|---|---|
| Serveur AD CS | certificat.ecotech.local/certsrv |
| Site web interne | portail.ecotech.local |
| Bastion Guacamole | bastion.ecotech.local |
| Proxy web externe | www.ecotech-solutions.com |
| Serveur messagerie | mail.ecotech.local |
| Serveur WSUS | wsus.ecotech.local |
| pfSense web admin | pfsense.ecotech.local |

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
