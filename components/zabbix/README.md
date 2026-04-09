# Supervision Centralisée - Infrastructure Zabbix

## Contexte du Projet

Dans le cadre de la refonte de l'infrastructure TSSR, la mise en place d'une solution de supervision centralisée est devenue critique pour passer d'une gestion réactive (correction des pannes après signalement) à une gestion proactive (anticipation des incidents).

Ce module Zabbix agit comme la tour de contrôle du système d'information. Il collecte, analyse et alerte sur l'état de santé de l'ensemble des équipements hétérogènes du parc (Serveurs Windows, Linux et Routeurs VyOS).

---

## Objectifs Stratégiques

L'implémentation de ce service répond à quatre besoins majeurs :

1.  **Centralisation :** Avoir une vue unique ("Single Pane of Glass") sur l'état de toute l'infrastructure, qu'elle soit sur site ou dans le cloud/DMZ.
2.  **Disponibilité :** Réduire les temps d'arrêt (Downtime) en détectant les signes avant-coureurs de panne (disque plein, surcharge CPU, arrêt de service).
3.  **Sécurité des Flux :** Garantir que les données de supervision ne puissent pas être interceptées ou falsifiées, via un chiffrement fort.
4.  **Universalité :** Capacité à surveiller des systèmes d'exploitation différents via une méthodologie unifiée.

---

## Architecture Technique

### La Stack Technologique
* **Moteur de Supervision :** Zabbix Server 7.0 LTS (Long Term Support).
* **Système d'Exploitation :** Debian 12 (Bookworm).
* **Base de Données :** MariaDB (Optimisée pour les écritures fréquentes).
* **Interface Web :** Serveur Apache2.
* **Agents de Collecte :** Zabbix Agent 2 (Version Go, pour une meilleure gestion des plugins et du chiffrement).

### Périmètre Supervisé
Le serveur central collecte les métriques des équipements suivants :
* **Serveurs Linux :** Surveillance système (CPU, RAM, I/O) et applicative (Docker, Web).
* **Serveurs Windows :** Surveillance des rôles critiques (Active Directory, DNS, DHCP).
* **Routeurs VyOS :** Surveillance des interfaces réseaux, de la bande passante et de l'état des tunnels VPN.

---

## Sécurité et Chiffrement (Security by Design)

Contrairement aux installations standards qui laissent souvent circuler les métriques en clair, cette infrastructure applique une politique de sécurité stricte.

### 1. Chiffrement des Communications (TLS)
Toutes les communications entre le serveur Zabbix et ses agents sont obligatoirement chiffrées.
* Utilisation de **Certificats X.509** (TLS) via une PKI interne.
* Le serveur rejette systématiquement toute connexion non chiffrée ou dont le certificat n'est pas signé par l'Autorité de Certification (CA) du projet.

### 2. Accès Web Sécurisé
L'interface d'administration n'est pas exposée directement.
* L'accès se fait via un **Reverse Proxy** (Apache/Nginx).
* Le flux est encapsulé en **HTTPS**.
* L'accès externe est filtré par le pare-feu de bordure (PfSense).

---

## Flux de Données (Matrice)

Le schéma logique des communications est le suivant :

| Source | Destination | Protocole | Rôle |
| :--- | :--- | :--- | :--- |
| **Agents (Infrastructure)** | **Serveur Zabbix** | TCP/10051 (PSK) | Remontée des alertes (Active Check) |
| **Serveur Zabbix** | **Agents (Infrastructure)** | TCP/10050 (PSK) | Interrogation des métriques (Passive Check) |
| **Proxy** | **Serveur Zabbix** | TCP/10051 (TLS) | Transmission sécurisée par certificat |

---

## Automatisation

Afin de garantir un déploiement homogène et rapide sur un parc grandissant, l'installation des agents n'est pas manuelle.

Une stratégie d'**Infrastructure as Code (IaC)** a été adoptée : des scripts de déploiement détectent automatiquement l'OS cible, installent la bonne version de l'agent, déposent les clé PSK et appliquent la configuration standardisée sans intervention humaine.

