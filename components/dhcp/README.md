DHCP
----

## 1. Rôle du service
Le serveur DHCP attribue automatiquement les paramètres réseau aux équipements clients qui se connectent au réseau (postes de travail, imprimantes, téléphones VoIP, points d'accès, etc.). Il fournit principalement :

- Adresse IP dynamique (ou fixe via réservation MAC)
- Masque de sous-réseau
- Passerelle par défaut
- Serveurs DNS à utiliser
- Nom de domaine
- Autres options spécifiques (ex : TFTP pour VoIP, NTP, etc.)

## 2. Position dans l'architecture

- Serveur principal : ECO-BDX-EX02 → 10.20.20.6 (VLAN 220)
- Serveur secondaire : ECO-BDX-EX01 → 10.20.20.5 (VLAN 220)

La redondance du service DHCP est assurée par un failover en mode Load Balancing (répartition 50/50) sur une architecture DHCP centralisée haute disponibilité, couvrant l’ensemble des VLANs utilisateurs dynamiques (VLAN 600 à 670), avec des relais DHCP activés sur le switches L3 (AX01) via des ip helper-address pointant vers les serveurs 10.20.20.5 et 10.20.20.6.

## 3. Prérequis

- Serveurs : Windows Server 2022
- Adresses IP statiques sur les deux serveurs DHCP
- Accès aux scopes pour chaque VLAN sur les deux serveurs
- NTP synchronisé sur les deux serveurs (même source de temps)
- Switch L3 : ports DHCP ouverts (UDP 67/68) depuis les VLANs clients vers les deux serveurs
- Communication bidirectionnelle entre les deux serveurs DHCP :
- TCP 647 (port Failover)
- ICMP (pour tests de connectivité)

*Domaine Active Directory fonctionnel (recommandé pour l’authentification et la gestion centralisée)*

## 4. Fonctionnalités

Des réservations DHCP par adresse MAC sont mises en place pour les équipements nécessitant une adresse IP fixe, tandis que le DHCP Failover en mode Load Balancing permet une répartition automatique des requêtes clients entre les deux serveurs, avec une synchronisation en temps réel des baux via le mécanisme MCLT et un délai de grâce (grace period) géré par Windows afin d’éviter les conflits d’adresses ; une configuration de split-scope manuelle reste possible en complément si nécessaire.

## 5. Documentation liée

- Configuration détaillée du DHCP Failover Load Balancing
- Liste des scopes par VLAN et plages d’adresses
