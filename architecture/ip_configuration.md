
# 1. Référentiel des VLANs et Adressage IP

L'infrastructure d'EcoTech Solutions utilise la plage privée **10.0.0.0/8** (RFC 1918).  
Ce choix permet une segmentation quasi illimitée tout en conservant une logique d'administration simplifiée.

## 1.1. Nomenclature d'adressage

L'adressage respecte une convention stricte de type **10.[Zone].[Index].[Hôte]** :

- **1er octet (10)** : Réseau racine de l'organisation.
- **2ème octet [Zone]** : Identifie la catégorie fonctionnelle (ex: 20 pour Infrastructure, 60 pour Métiers).
- **3ème octet [Index]** : Identifie le sous-réseau spécifique (dérivé de l'ID VLAN).
- **4ème octet [Hôte]** : Identifie la machine (statique ou DHCP).

**Exemple :** **10.60.20.50** → Zone Métiers (60) / VLAN 620 (20) / Poste DHCP (50)

## 1.2. Structure d'Adressage par Catégorie Fonctionnelle

Cette organisation du **2ème octet** permet d'identifier visuellement la fonction d'un réseau à partir de son adresse IP.

| 2ème Octet | Catégorie Fonctionnelle | Plage VLANs | Usage Principal |
|------------|------------------------|-------------|-----------------|
| **20** | Infrastructure | 200-299 | Cœur technique (Proxmox, AD, Fichiers, Backup) |
| **40** | Transit | 400-499 | Réseaux point-à-point (pfSense ↔ VyOS) |
| **50** | Bordure | 500-599 | Services exposés (DMZ, Bastion) |
| **60** | Métiers | 600-799 | Utilisateurs et départements |
| **80** | Mobilité | 800-899 | WiFi et accès sans-fil |
| **99** | Sécurité | 999 | Quarantaine et isolation |

**Logique de mémorisation :**
- Une IP en **10.20.x.x** → Infrastructure critique
- Une IP en **10.60.x.x** → Poste utilisateur métier
- Une IP en **10.50.x.x** → Service de bordure (DMZ/Bastion)

## 1.3. Plan d'Adressage Détaillé par Niveau de Sécurité (Tiering)

L'infrastructure applique le **modèle de Tiering ANSSI** pour isoler les ressources critiques.  
Les VLANs sont organisés en 3 niveaux de confiance.

### Tier 0 - Infrastructure Critique (Niveau de confiance : Maximal)

**Principe** : Aucun accès Internet direct. Accessible uniquement depuis les postes d'administration (Tier 1).

| VLAN | Nom | Réseau | Catégorie | Usage | Particularité |
|------|-----|--------|-----------|-------|---------------|
| **200** | Management | 10.**20**.0.0/28 | Infrastructure | Accès SSH Proxmox, switches | Admin uniquement |
| **250** | Stockage | 10.**20**.50.0/29 | Infrastructure | Baie iSCSI/NFS pour Bareos | **Non-routé** (L2) |

---

### Tier 1 - Services et Administration (Niveau de confiance : Élevé)

**Principe** : Accès Internet restreint (via proxy uniquement). Isolation stricte des flux d'administration.

| VLAN | Nom | Réseau | Catégorie | Usage | Services Hébergés |
|------|-----|--------|-----------|-------|-------------------|
| **210** | Admin | 10.**20**.10.0/28 | Infrastructure | Postes d'administration (PAW) | Postes GX-username |
| **220** | Core | 10.**20**.20.0/27 | Infrastructure | Services d'identité et réseau | AD-01, AD-02, DNS, DHCP |
| **230** | Fichiers | 10.**20**.30.0/28 | Infrastructure | Serveur de fichiers métier | Partages SMB départementaux |
| **240** | Backup | 10.**20**.40.0/29 | Infrastructure | Orchestration sauvegarde | Bareos (vers VLAN 250) |
| **500** | DMZ | 10.**50**.0.0/28 | Bordure | Zone exposée Internet | Proxy Squid, Serveur Web |
| **520** | Administration | 10.**50**.20.0/28 | Bordure | Zone d'administration isolée | Serveur Bastion |

---

### Tier 2 - Utilisateurs et Métiers (Niveau de confiance : Standard)

**Principe** : Accès Internet autorisé via proxy. Isolation inter-départements par défaut.

| VLAN    | Nom            | Réseau            | Catégorie | Département            | Effectif       |
| ------- | -------------- | ----------------- | --------- | ---------------------- | -------------- |
| **600** | Direction      | 10.**60**.0.0/24  | Métiers   | Direction générale     | 6              |
| **610** | DSI            | 10.**60**.10.0/24 | Métiers   | Équipe IT/Support      | 13             |
| **620** | RH             | 10.**60**.20.0/24 | Métiers   | Ressources Humaines    | 24             |
| **630** | Commercial     | 10.**60**.30.0/24 | Métiers   | Service Commercial     | 42             |
| **640** | Finance/Compta | 10.**60**.40.0/24 | Métiers   | Finance & Comptabilité | 16             |
| **650** | Communication  | 10.**60**.50.0/24 | Métiers   | Communication          | 38             |
| **660** | Développement  | 10.**60**.60.0/24 | Métiers   | Développeurs           | 116            |
| **670** | VoIP           | 10.**60**.70.0/23 | Métiers   | Téléphonie IP          | 243 téléphones |
| **800** | WiFi           | 10.**80**.0.0/23  | Mobilité  | Accès sans-fil 802.1X  | Variable       |

---

### Zones Techniques

**Principe** : Réseaux de transit point-à-point. Aucun hôte final autorisé.

| Réseau            | Type           | Catégorie | Usage                 | Équipements           |
| ----------------- | -------------- | --------- | --------------------- | --------------------- |
| 10.**10**.10.0/29 | Bridge vmbr514 | Transit   | pfSense-1 ↔ pfSense-2 | DX01 (.1) ↔ DX02 (.2) |
| 10.**40**.0.0/29  | Bridge vmbr510 | Transit   | VIP ↔ VyOS-1          | VIP (.1) ↔ DX03 (.2)  |
| 10.**40**.10.0/29 | Bridge vmbr512 | Transit   | VyOS-1 ↔ VyOS-2       | DX03 (.1) ↔ DX04 (.2) |

**Note** : Ces réseaux ne sont **pas des VLANs 802.1Q** mais des bridges Proxmox isolés.

---

### Zone de Sécurité

**Principe** : Isolation totale. Aucun accès sortant autorisé.

| VLAN | Nom | Réseau | Catégorie | Usage |
|------|-----|--------|-----------|-------|
| **999** | Quarantaine | 10.**99**.99.0/24 | Sécurité | Isolation hôtes compromis |

## 1.4. Principes d'administration et de sécurité

- **Logique Visuelle** : La corrélation entre l'ID du VLAN et l'IP (ex: VLAN **62**0 → 10.60.**20**.0) facilite la mémorisation pour les techniciens et accélère le diagnostic lors de l'analyse des logs.

- **Sécurité par segmentation** : L'utilisation du deuxième octet par catégorie permet de créer des règles de pare-feu globales simplifiées. Par exemple, une règle unique peut bloquer tout flux provenant de la zone Mobilité (**10.80.0.0/16**) vers le cœur de l'infrastructure (**10.20.0.0/16**).

- **Scalabilité** : Les réseaux métiers sont dimensionnés en **/24** pour absorber la croissance de l'entreprise (recrutements) sans nécessiter de re-adressage complexe.

# 2. Configuration IP par matériel

Cette section détaille l'adressage statique des interfaces pour chaque équipement critique de l'infrastructure.

## 2.1. Cluster pfSense HA Complet (Architecture Production)

### Configuration complète avec CARP sur toutes les interfaces

| Équipement | Interface | Bridge | Adresse IP | Rôle |
|------------|-----------|--------|------------|------|
| **VIP (CARP)** | WAN | vmbr1 | **10.0.0.3/29** | IP virtuelle cluster (Passerelle : 10.0.0.1) |
| **DX01** | WAN | vmbr1 | 10.0.0.4/29 | Membre 1 (VHID 10, Skew 0) |
| **DX02** | WAN | vmbr1 | 10.0.0.5/29 | Membre 2 (VHID 10, Skew 100) |
| | | | | |
| **VIP (CARP)** | LAN | vmbr510 | **10.40.0.1/29** | IP virtuelle cluster |
| **DX01** | LAN | vmbr510 | 10.40.0.3/29 | Membre 1 (VHID 1, Skew 0) |
| **DX02** | LAN | vmbr510 | 10.40.0.4/29 | Membre 2 (VHID 1, Skew 100) |
| | | | | |
| **VIP (CARP)** | DMZ | vmbr511 | **10.50.0.1/28** | IP virtuelle cluster |
| **DX01** | DMZ | vmbr511 | 10.50.0.3/29 | Membre 1 (VHID *, Skew 0) |
| **DX02** | DMZ | vmbr511 | 10.50.0.4/29 | Membre 2 (VHID *, Skew 100) |
| | | | | |
| **DX01** | SYNC | vmbr514 | 10.10.10.1/29 | Synchronisation pfsync |
| **DX02** | SYNC | vmbr514 | 10.10.10.2/29 | Synchronisation pfsync |
| | | | | |
| **VIP (CARP)** | Administration | vmbr515 | **10.50.20.1/28** | IP virtuelle cluster |
| **DX01** | DMZ | vmbr511 | 10.50.0.3/29 | Membre 1 (VHID 2, Skew 0) |
| **DX02** | DMZ | vmbr511 | 10.50.0.4/29 | Membre 2 (VHID 2, Skew 100) |

### Caractéristiques de haute disponibilité

- **Protocole** : CARP (Common Address Redundancy Protocol)
- **Mode** : Actif/Passif sur toutes les interfaces
- **Synchronisation** : Configuration (XMLRPC) + États (pfsync)
- **Temps de basculement** : < 3 secondes
- **Maintien des connexions** : Tables d'état synchronisées
- **Tolérance de panne** : 100% (toutes interfaces)

### Notes techniques

**VIP WAN (10.0.0.3) :**
- Utilisée par VyOS comme passerelle par défaut (0.0.0.0/0 via 10.40.0.1)
- Utilisée pour le NAT sortant de tout le réseau interne
- Point d'entrée unique vers Internet (haute disponibilité totale)

**IPs individuelles (.4 et .5) :**
- Permettent le monitoring séparé de chaque nœud depuis Internet
- Facilitent le troubleshooting (ping/traceroute vers un nœud spécifique)
- Utilisées pour la synchronisation initiale du cluster

## 2.2. Infrastructure et Serveurs Critiques (Tableau d'affectation des hôtes)

Pour maintenir une cohérence d'administration, les serveurs utilisent systématiquement l'IP **.5** (ou une plage commençant à .5) dans leur VLAN respectif.

| **Nom (VM/CT)**  | **Serveur / Service**   | **VLAN** | **Adresse IP** | **Passerelle (GW)** | **Rôle / Justification**              |
| ---------------- | ----------------------- | -------- | -------------- | ------------------- | ------------------------------------- |
| **ECO-BDX-GX01** | **PC d'administration** | **210**  | 10.20.10.2     | 10.20.10.1          | Poste de pilotage (Management Tier 1) |
| **ECO-BDX-GX02** | **PC d'administration** | **210**  | 10.20.10.3     | 10.20.10.1          | Poste de pilotage (Management Tier 1) |
| **ECO-BDX-EX01** | **Windows AD-01**       | **220**  | 10.20.20.5     | 10.20.20.1          | DC Principal (Core) / DNS / DHCP      |
| **ECO-BDX-EX02** | **Windows AD-02**       | **220**  | 10.20.20.6     | 10.20.20.1          | DC Secondaire (GUI) / DNS / DHCP      |
| **ECO-BDX-EX03** | **Serveur de Fichiers** | **230**  | 10.20.30.5     | 10.20.30.1          | Serveur de données Métiers            |
| **ECO-BDX-EX04** | **GLPI/Logs**           | **220**  | 10.20.20.18    | 10.20.20.1          | Serveur de données Métiers            |
| **ECO-BDX-FX01** | **Bareos (Backup)**     | **240**  | 10.20.40.5     | 10.20.40.1          | Orchestrateur de sauvegarde           |
| **ECO-BDX-EX06** | **Stockage Isolé**      | **250**  | 10.20.50.5     | _Aucune_            | Interface de stockage (L2)            |
| **ECO-BDX-EX07** | **Web (LAN)**           | **220**  | 10.20.20.7     | 10.20.20.1          | Serveur Web Interne                   |
| **ECO-BDX-EX08** | **Web (DMZ)**           | **500**  | 10.50.0.6      | 10.50.0.1           | Site EcoTech                          |
| **ECO-BDX-EX09** | **Proxy (DMZ)**         | **500**  | 10.50.0.5      | 10.50.0.1           | Sortie Web                            |
| **ECO-BDX-EX10** | **Zabbix**              | **220**  | 10.20.20.12    | 10.20.20.1          | Supervision                           |
| **ECO-BDX-EX11** | **Antenne Zabbix**      | **220**  | 10.20.20.13    | 10.20.20.1          | Supervision                           |
| **ECO-BDX-EX12** | **AD Cert Server**      | **220**  | 10.20.20.15    | 10.20.20.1          | Serveur de certificats                |
| **ECO-BDX-EX13** | **iRedMail**            | **220**  | 10.20.20.14    | 10.20.20.1          | Messagerie                            |
| **ECO-BDX-EX14** | **FreePBX**             | **220**  | 10.20.20.20    | 10.20.20.1          | VoIP                                  |
| **ECO-BDX-EX15** | **Bastion**             | **520**  | 10.50.20.5     | 10.50.20.1          | Administration                        |
| **ECO-BDX-EX16** | **WSUS**                | **220**  | 10.20.20.17    | 10.20.20.1          | Serveur de mises à jour centralisé    |
| **ECO-BDX-EX17** | **Windows AD-03**       | **220**  | 10.20.20.16    | 10.20.20.1          | DC Secondaire (CLI)                   |


## 2.3. Récapitulatif de la hiérarchie des hôtes (Convention .x)

Pour faciliter la mémorisation lors des configurations, nous appliquons cette convention sur l'ensemble du projet :

- **10.[Zone].[Index].1** : Toujours la **Passerelle par défaut** (Gateway).
- **10.[Zone].[Index].5 à 49** : Réservé aux **Serveurs et IPs Statiques**.
- **10.[Zone].[Index].50 à 250** : Plage de distribution **DHCP** (pour les utilisateurs).
- **10.[Zone].[Index].254** : **Interface d'administration** réseau (Switch/Routeur).

# 3. Étendues DHCP et Réservations

Afin de garantir une gestion fluide des 251 collaborateurs et de leurs terminaux, le service DHCP est centralisé sur le serveur **Windows AD (10.20.20.5)**.  
Les adresses sont distribuées à partir de l'IP **.50** pour laisser une plage de sécurité aux équipements à IP fixe (imprimantes, copieurs, postes VIP).

## 3.1. Étendues DHCP (Scopes)

Tous les scopes utilisent les paramètres suivants, sauf mention contraire :

- **DNS Primaire :** 10.20.20.5 (DC01)
- **DNS Secondaire :** 10.20.20.6 (DC02)
- **Suffixe DNS :** **ecotech.local**
- **Durée du bail :** 8 heures (optimisé pour la mobilité)

| **VLAN** | **Réseau**    | **Plage DHCP (Pool)**      | **Passerelle (GW)** | **Usage**      |
| -------- | ------------- | -------------------------- | ------------------- | -------------- |
| **600**  | 10.60.0.0/24  | 10.60.0.50 - 10.60.0.250   | 10.60.0.1           | Direction      |
| **610**  | 10.60.10.0/24 | 10.60.10.50 - 10.60.10.250 | 10.60.10.1          | DSI            |
| **620**  | 10.60.20.0/24 | 10.60.20.50 - 10.60.20.250 | 10.60.20.1          | DRH            |
| **630**  | 10.60.30.0/24 | 10.60.30.50 - 10.60.30.250 | 10.60.20.1          | Commercial     |
| **640**  | 10.60.40.0/24 | 10.60.40.50 - 10.60.40.250 | 10.60.40.1          | Finance/Compta |
| **650**  | 10.60.50.0/24 | 10.60.50.50 - 10.60.50.250 | 10.60.50.1          | Communication  |
| **660**  | 10.60.60.0/24 | 10.60.60.50 - 10.60.60.250 | 10.60.60.1          | Développement  |
| **670**  | 10.60.70.0/23 | 10.60.70.50 - 10.60.70.250 | 10.60.70.1          | VoIP           |
| **800**  | 10.80.0.0/24  | 10.80.0.50 - 10.80.0.250   | 10.80.0.1           | WiFi RADIUS    |
| **999**  | 10.99.99.0/24 | 10.99.99.99 - 10.99.99.199 | 10.99.99.1          | Quarantaine    |

## 3.2. Mécanisme de Relais DHCP (IP Helper)

Étant donné que le serveur DHCP est situé dans le **VLAN 220** et que les clients sont dans des VLANs différents, un agent de relais est configuré.

- **Emplacement du Relais :** Routeur VyOS (Interfaces virtuelles eth1.x)
- **Configuration :** Sur chaque interface SVI des VLANs 600, 610, 620, 630, 640, 650, 660, 670 et 800, l'adresse de l'assistant (Helper-Address) pointe vers **10.20.20.5 et .6**.












