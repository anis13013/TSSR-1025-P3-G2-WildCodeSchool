<span id="haut-de-page"></span>
# Serveur Bastion — Apache Guacamole

---

## Table des matières

- [Serveur Bastion — Apache Guacamole](#serveur-bastion--apache-guacamole)
  - [Table des matières](#table-des-matières)
  - [1. Rôle du service](#1-rôle-du-service)
  - [2. Position dans l'architecture](#2-position-dans-larchitecture)
  - [3. Prérequis](#3-prérequis)
  - [4. Fonctionnalités](#4-fonctionnalités)

## 1. Rôle du service

Le serveur Bastion est le point d'accès unique et sécurisé pour l'administration des serveurs de l'infrastructure EcoTech Solutions. Il centralise tous les accès RDP et SSH vers les machines critiques et enregistre l'ensemble des sessions d'administration.

Il fournit :
- Accès distant sécurisé via navigateur web (HTML5).
- Traçabilité complète des sessions d'administration.
- Authentification centralisée via Active Directory (LDAP).
- Isolation des flux d'administration du reste du réseau.
- Cloisonnement des privilèges selon les profils utilisateurs.

## 2. Position dans l'architecture

- **Serveur** : ECO-BDX-EX15 (CT 139) avec IP statique `10.50.20.5/28`.
- **VLAN** : VLAN 520 (Bastion) — segment réseau isolé dédié.
- **Passerelle** : VIP CARP pfSense `10.50.20.1` (haute disponibilité).
- **Accès interne** : VLAN 210 (Postes d'administration GX) via HTTPS.
- **Accès externe** : Internet (WAN) via NAT pfSense.
- **Reverse Proxy** : nginx dans docker pour la terminaison SSL/TLS.

## 3. Prérequis

- **Pare-feu** :
  - Règles pfSense autorisant le VLAN 210 → Bastion (TCP/443)
  - Règles pfSense autorisant le Bastion → Serveurs (TCP/22, 3389)
  - NAT pfSense pour l'accès externe WAN → Bastion (TCP/443)
- **DNS** : Entrée `bastion.ecotech.local` pointant vers `10.50.20.5` dans le DNS interne.
- **Certificat SSL** : Certificat délivré par `ECO-BDX-EX12`.

## 4. Fonctionnalités

- **Interface web Apache Guacamole** :
  - Accès RDP, SSH, VNC, Telnet sans client lourd.
  - Protocole HTML5 (WebSocket) — compatible avec tous les navigateurs modernes.
  
- **Architecture en conteneurs Docker** :
  - **guacamole** : Interface utilisateur (port 8080).
  - **guacd** : Daemon de connexion (gestion des protocoles RDP/SSH).
  - **postgres** : Base de données (utilisateurs, connexions, historique).

- **Authentification Active Directory (LDAP)** :
  - Synchronisation des comptes utilisateurs via LDAP.
  - Mappage des groupes AD aux permissions Guacamole.
  - Authentification unique (SSO partiel via identifiants AD).

- **Terminaison SSL via Proxy Nginx** :
  - pfSense intercepte les connexions HTTPS (port 443).
  - Nginx déchiffre le trafic et le transmet en HTTP vers Guacamole.
  - Isolation du bastion : aucun accès HTTP direct depuis l'extérieur.

- **Traçabilité et audit** :
  - Historique des connexions stocké dans PostgreSQL.
  - Logs d'accès centralisés (pfSense + Docker).
  - Option d'enregistrement vidéo des sessions (désactivée par défaut).

- **Isolation réseau** :
  - VLAN 520 dédié, séparé de la DMZ publique (VLAN 500).
  - Principe du moindre privilège : le bastion ne peut joindre que les serveurs d'infrastructure (VLANs 220, 230, 240).
  - Aucun accès sortant vers les VLANs métiers (600-800).

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
