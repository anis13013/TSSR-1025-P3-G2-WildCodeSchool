# 1. Routeur Backbone (DX03)

## 1.1 Rôle et Place dans l'architecture - DX03
Ce routeur assure la fonction de **Backbone de Transit**. Il sert de "pont" entre les pare-feux périmétriques (PfSense DX01 - DX02) et le cœur de réseau interne (AX01).
Il ne porte **aucun VLAN utilisateur** et ne fait pas de NAT. Son rôle est purement le routage de paquets entre les zones de transit. Il permet non seulement de superviser le trafic réseau, mais aussi de prévoir l’évolution de l’infrastructure. Grâce à lui, il est possible d’analyser en détail les flux entre les différents segments et de détecter les éventuels goulots d’étranglement ou zones saturées.

## 1.2 Topologie Logique

Cette section décrit comment les équipements sont connectés, en particulier la gestion de la sécurité en entrée de réseau.

## Le Cluster de Pare-feu (DX01 & DX02)
L'accès vers Internet est géré par deux pare-feu pfSense (**DX01** et **DX02**) configurés en **mode cluster**.

**Qu'est-ce qu'un Cluster ?**
C'est une technique qui consiste à faire fonctionner deux machines comme une seule pour assurer la **Haute Disponibilité**.
Si le pare-feu principal tombe en panne, le second prend le relais immédiatement sans couper la connexion. Pour les autres équipements, ce changement est invisible car ils communiquent avec une **adresse IP virtuelle (VIP)** unique, et non avec les adresses physiques des machines.

## Lien avec le Routeur Backbone (DX03)
Le routeur **Backbone (DX03)** est situé dans la zone de **TRANSIT 1** (`10.40.0.0/29`).
Il permet de faire le lien entre le cœur du réseau et la sortie Internet.

Pour garantir la continuité de service, ce routeur n'envoie pas ses données vers DX01 ou DX02 directement, mais vers l'**IP Virtuelle (VIP)** du cluster. Ainsi, la sortie Internet reste fonctionnelle même si un des pare-feu est éteint.

## 1.3 Configuration du Routage (Static Routing)

Le routage sur l'équipement **DX03** est configuré de manière statique pour aiguiller les paquets dans deux directions.

### 1.4 Route par défaut (Vers Internet)
Tout le trafic qui n'est pas destiné au réseau local est envoyé vers l'extérieur.

**Destination :** 0.0.0.0/0 (Internet)
**Interface de sortie :** eth0 (TRANSIT 1)
**Passerelle (Next Hop) (VIP) :** 10.40.0.1 *L'adresse IP virtuelle (VIP) du cluster pfSense*.

### 1.5 Route vers l'interne (Vers le Cœur de Réseau)
Le trafic destiné aux serveurs ou aux PC utilisateurs est renvoyé vers l'intérieur du réseau.

**Destination :** Les réseaux internes de l'entreprise.
**Interface de sortie :** eth1 (TRANSIT 2)
**Passerelle (Next Hop) :** 10.40.10.2 *L'adresse du routeur Cœur L3 AX01*.

### 1.6 Table de Routage - DX03

*Pour le moment le routeur posséde ces routes spécifiques, Il peut en avoir de nouvelles ou quelques changements celon l'avancée du projet*

- **eth0 via DX01 & DX02**
- **eth1 via AX01**

| Réseau Destination | Masque (CIDR) | Prochain Saut (Next-Hop) | Interface | Description |
|-------------------|---------------|-------------------------|-----------|-------------|
| 0.0.0.0           | /0            | 10.40.10.1              | eth0      | Route par défaut (Internet via PfSense) |
| 10.50.0.0         | /28           | 10.40.10.1              | eth0      | Zone DMZ |
| 10.20.0.0         | /28           | 10.40.20.2              | eth1      | VLAN 200 - MGMT (Core) |
| 10.20.10.0        | /28           | 10.40.20.2              | eth1      | VLAN 210 - Admin IT |
| 10.20.20.0        | /27           | 10.40.20.2              | eth1      | VLAN 220 - Serveurs |
| 10.60.0.0         | /24           | 10.40.20.2              | eth1      | VLAN 600 - Direction |
| 10.60.10.0        | /24           | 10.40.20.2              | eth1      | VLAN 610 - DSI |
| 10.60.20.0        | /24           | 10.40.20.2              | eth1      | VLAN 620 - DRH |
| 10.60.30.0        | /24           | 10.40.20.2              | eth1      | VLAN 630 - Commercial |
| 10.60.40.0        | /24           | 10.40.20.2              | eth1      | VLAN 640 - Finance / Compta |
| 10.60.50.0        | /24           | 10.40.20.2              | eth1      | VLAN 650 - Communication |
| 10.60.60.0        | /24           | 10.40.20.2              | eth1      | VLAN 660 - Développement |
| 10.60.70.0        | /23           | 10.40.20.2              | eth1      | VLAN 670 - VOIP / IOT |

## 1.7 Services d'Administration
- **SSH :** Port 22
- **Accès :** Restreint aux IPs d'administration (VLAN 210 via le routage).

# 2. Routeur Cœur de Réseau (AX01)

## 2.1 Rôle et Place dans l'architecture - AX01
Ce routeur assure la fonction de **Cœur de Réseau L3** (Layer 3). Il sert de "pont" entre la zone de transit (vers le Backbone DX03) et l'ensemble des réseaux internes de l'entreprise (Zones Infra et Utilisateurs).
Contrairement au routeur de transit, il porte **tous les VLANs utilisateurs** et assure le routage Inter-VLAN. Son rôle est de centraliser les passerelles par défaut des différents services. Il permet de segmenter le trafic interne et d'appliquer les premières politiques de sécurité entre les zones. Grâce à lui, il est possible de garantir que les flux entre les serveurs et les utilisateurs transitent par un point de contrôle unique.

## 2.2 Topologie Logique

Cette section décrit comment les équipements sont connectés, en particulier la gestion des interfaces virtuelles et du lien montant.

## Lien avec le Routeur Backbone (DX03)
La sortie vers l'extérieur est assurée par le routeur **Backbone (DX03)** situé dans la zone de **TRANSIT 2** (**10.40.10.0/29**).

**Pourquoi ce lien ?**
C'est l'unique porte de sortie pour tout le trafic interne qui doit aller sur Internet. Le Cœur de Réseau (AX01) ne connecte pas directement les pare-feu ; il délègue cette tâche au Backbone pour maintenir une architecture hiérarchique propre.

## Gestion des VLANs (Interface Trunk)
L'interface descendante (eth1) est configurée en mode **Trunk (802.1Q)**.
Elle ne porte pas une adresse IP unique, mais héberge de multiples **Interfaces Virtuelles (VIF)**.

Chaque VIF correspond à un VLAN (DSI, RH, Serveurs...) et agit comme la passerelle pour les machines de ce réseau. Cela permet de transporter plusieurs réseaux logiques sur un seul lien physique vers les switchs de distribution.

## 2.3 Configuration du Routage (Static Routing)

Le routage sur l'équipement **AX01** est configuré de manière statique pour gérer la sortie vers Internet et la distribution locale.

## 2.4 Route par défaut (Vers Internet)
Tout le trafic qui n'est pas destiné au réseau local est envoyé vers le Backbone.

**Destination :** 0.0.0.0/0 (Internet)
**Interface de sortie :** eth0 (TRANSIT 2)
**Passerelle (Next Hop) :** 10.40.10.1 *L'adresse du routeur Backbone DX03*.

## 2.5 Route vers l'interne (Réseaux Connectés)
Le trafic destiné aux serveurs ou aux PC utilisateurs est traité localement via les interfaces virtuelles.

**Destination :** Les réseaux internes (VLANs).
**Interface de sortie :** eth1.x (VIFs)
**Type :** Connecté (C) *Le routeur connaît ces réseaux car il y est directement connecté*.

## 2.6 Table de Routage - AX01

*Pour le moment le routeur possède ces routes spécifiques, Il peut en avoir de nouvelles ou quelques changements selon l'avancée du projet*

- **eth0 via DX03**
- **eth1 (VIFs) Connectés directement**

| Réseau Destination | Masque (CIDR) | Prochain Saut (Next-Hop) | Interface | Description |
|-------------------|---------------|-------------------------|-----------|-------------|
| 0.0.0.0           | /0            | 10.40.10.1              | eth0      | Route par défaut (Vers Backbone) |
| 10.20.0.0         | /28           | interface VLAN connectée                | eth1.200  | VLAN 200 - MGMT  |
| 10.20.10.0        | /28           | interface VLAN connectée               | eth1.210  | VLAN 210 - Admin IT |
| 10.20.20.0        | /27           | interface VLAN connectée                 | eth1.220  | VLAN 220 - Serveurs |
| 10.60.0.0         | /24           | interface VLAN connectée               | eth1.600  | VLAN 600 - Direction |
| 10.60.10.0        | /24           | interface VLAN connectée                 | eth1.610  | VLAN 610 - DSI |
| 10.60.20.0        | /24           | interface VLAN connectée                | eth1.620  | VLAN 620 - DRH |
| 10.60.30.0        | /24           | interface VLAN connectée               | eth1.630  | VLAN 630 - Commercial |
| 10.60.40.0        | /24           | interface VLAN connectée                | eth1.640  | VLAN 640 - Finance / Compta |
| 10.60.50.0        | /24           | interface VLAN connectée                | eth1.650  | VLAN 650 - Communication |
| 10.60.60.0        | /24           | interface VLAN connectée               | eth1.660  | VLAN 660 - Développement |
| 10.60.70.0        | /23           | interface VLAN connectée                 | eth1.670  | VLAN 670 - VOIP / IOT |

## 2.7 Services Associés
- **SSH :** Port 22 (Administration).
- **DHCP-Relay :** Ce service est configuré sur les interfaces des VLANs utilisateurs pour relayer les requêtes DHCP vers le serveur d'infrastructure.
    - **Adresse Cible :** `10.20.20.8`
- **Firewall :** Le service de pare-feu pour le filtrage inter-VLAN a été ajouté. *Statut : En cours de finalisation ou suppression selon l'évolution des besoins.*

























