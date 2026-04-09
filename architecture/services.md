## 1. Inventaire Global des Services

L'infrastructure s'appuie sur une pile de services Microsoft et Open Source pour garantir l'agilité et la sécurité du SI.

| Service              | Technologie             | Zone (VLAN) | Importance   |
| -------------------- | ----------------------- | ----------- | ------------ |
| **Identité (AD DS)** | Windows Server 2022     | 220         | **Vitale**   |
| **Résolution (DNS)** | Windows DNS             | 220         | **Vitale**   |
| **Adressage (DHCP)** | Windows DHCP (Failover) | 220         | **Haute**    |
| **Voix (VoIP)**      | FreePBX (Asterisk)      | 640         | **Métier**   |
| **Sauvegarde**       | Bareos                  | 240         | **Haute**    |
| **Filtrage Web**     | Squid Proxy             | 500         | **Sécurité** |
| **Accès Distant**    | VPN SSL (pfSense)       | 510         | **Métier**   |

---

## 2. Fiches Détail par Service

### 2.1. Services de Base (Core Tier 0)

#### **AD DS (Active Directory Domain Services)**

- **Rôle :** Centralisation de l'identité des 251 utilisateurs et des ordinateurs. Gestion des stratégies de sécurité (GPO).
- **Interdépendances :** Requiert un service DNS fonctionnel.
- **Exposition :** **Interne uniquement**. Accessible depuis tous les VLANs utilisateurs (Ports 88, 445, 389).
- **Particularité :** Déploiement en duo (AD-01 GUI + AD-02 Core) pour la haute disponibilité de l'annuaire.

#### **DNS (Domain Name System)**

- **Rôle :** Traduction des noms (ex: `srv-files.ecotech.local`) en adresses IP.
- **Interdépendances :** Intégré à l'Active Directory.
- **Exposition :** **Interne** (résolution locale) et **Externe** (via forwarders pfSense pour la navigation web).

#### **DHCP (Dynamic Host Configuration Protocol)**

- **Rôle :** Attribution automatique des configurations IP, incluant l'**Option 66** pour l'auto-provisionnement des 243 téléphones VoIP.
- **Interdépendances :** Nécessite l'agent **DHCP Relay** configuré sur le routeur VyOS pour atteindre les différents VLANs.
- **Exposition :** **Interne**.

---

### 2.2. Services Métiers et Sécurité (Tier 1)

#### **VoIP (FreePBX)**

- **Rôle :** Gestion des communications vocales internes et externes.
- **Interdépendances :** Dépend du DHCP (pour les IPs des postes) et du pfSense (pour le Trunk SIP externe).
- **Exposition :** **Hybride**. Interne pour les postes téléphoniques, Externe pour la liaison avec l'opérateur.

#### **Sauvegarde (Bareos)**

- **Rôle :** Protection des données contre les pannes et ransomwares.
- **Interdépendances :** Accès direct au **VLAN 250 (L2)** pour le stockage et accès aux agents sur les serveurs AD/Fichiers via le réseau.
- **Exposition :** **Interne strictement isolée**.

---

## 3. Matrice des Interdépendances (Ordre Critique)

Le schéma ci-dessous illustre l'ordre logique dans lequel les services doivent être démarrés après une coupure totale (Cold Boot) :

1. **Niveau 1 (Réseau) :** Hyperviseur Proxmox > pfSense > VyOS.
2. **Niveau 2 (Fondation) :** AD-01 & AD-02 (DNS doit être stable avant tout le reste).
3. **Niveau 3 (Adressage) :** Activation du service DHCP (permet aux postes et serveurs Tier 1 de prendre leurs IPs).
4. **Niveau 4 (Applicatifs) :** FreePBX, Serveur de Fichiers, Proxy.
5. **Niveau 5 (Protection) :** Bareos (doit démarrer en dernier pour sauvegarder les états stables des autres services).

---

## 4. Ordre Logique de Mise en Place (Projet)

Pour ton dossier TSSR, voici l'ordre dans lequel tu dois documenter ton installation :

1. **Configuration Réseau (Sprint 1-2) :** Création des bridges Proxmox, installation du VyOS et du pfSense. Tests de connectivité (Pings inter-VLANs).
2. **Services Core (Sprint 3) :** Installation d'AD-01. Promotion du domaine `ecotech.local`. Configuration du DNS.
3. **Renforcement Core (Sprint 4) :** Installation d'**AD-02 en mode Core**. Mise en place du Failover DHCP et des agents de relais sur VyOS.
4. **Services Métiers :** Déploiement du serveur de fichiers et de la VoIP (FreePBX).
5. **Sécurité et Finitions :** Installation de Bareos, configuration des logs et durcissement des règles de pare-feu finales.
