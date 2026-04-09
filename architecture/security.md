## 1. Principes de sécurité retenus

La stratégie de cybersécurité d'EcoTech Solutions repose sur des piliers reconnus par l'ANSSI, adaptés à une infrastructure virtualisée.

### 1.1. Défense en profondeur

Nous n'accordons pas de confiance exclusive à une seule barrière. La sécurité est multicouche :

- **Périmètre :** Filtrage étatique (Stateful) et IDS/IPS sur le pfSense.
- **Réseau :** Segmentation stricte par VLANs et ACLs sur le routeur VyOS.
- **Système :** Durcissement des OS (Hardening) et déploiement de **Windows Server Core** pour réduire la surface d'attaque.
- **Données :** Chiffrement et isolation physique du stockage de sauvegarde.

### 1.2. Le principe du moindre privilège

Chaque utilisateur ou service ne dispose que des accès strictement nécessaires à sa fonction :

- **Utilisateurs :** Droits "Utilisateurs standards" sans privilèges d'installation.
- **Services :** Les comptes de service (ex: pour Bareos ou les relais DHCP) ont des droits restreints aux protocoles et dossiers cibles.
- **Administrateurs :** Utilisation de comptes nominatifs distincts des comptes personnels pour éviter l'exposition des identifiants "Domain Admin" sur les postes de travail.

### 1.3. Modèle d'Administration en Tiers (Tier Model)

Pour contrer les attaques de type "mouvement latéral" ou "Pass-the-Hash", nous appliquons le modèle de segmentation administrative :

- **Tier 0 (Cœur d'Identité) :** Contrôleurs de domaine (**AD-01** et **AD-02 Core**). Seuls les administrateurs du Tier 0 peuvent s'y connecter.
- **Tier 1 (Serveurs) :** Serveurs de fichiers, de base de données et de sauvegarde.
- **Tier 2 (Postes de travail) :** Postes des 251 collaborateurs et terminaux VoIP.  
_Note : Un administrateur ne peut jamais se connecter à un Tier supérieur depuis un Tier inférieur._

### 1.4. Réduction de la Surface d'Attaque

Le principe est de supprimer tout service ou interface inutile :

- **Windows Server Core :** Le choix de ce mode pour **AD-02** élimine l'interface graphique, réduisant ainsi les vulnérabilités exploitables et la fréquence des redémarrages pour mises à jour.
- **Isolation du Stockage :** Le **VLAN 250** est configuré en mode **non-routé**. Il est donc techniquement impossible d'y accéder par rebond réseau, protégeant ainsi les sauvegardes contre les ransomwares.

### 1.5. Approche Zero Trust

Bien que le réseau soit segmenté, nous appliquons une logique de vérification systématique :

- L'appartenance à un VLAN ne donne pas droit automatiquement à une ressource.
- Tout flux inter-VLAN doit faire l'objet d'une règle d'autorisation explicite ("Deny All" par défaut).
- Authentification forte via **RADIUS (802.1X)** pour tous les accès Wi-Fi et filaires.

## 2. Zones sensibles et Segmentation

L'architecture réseau est découpée en zones étanches afin de limiter les mouvements latéraux en cas de compromission d'un poste de travail. Nous utilisons le modèle d'administration par **Tiers** pour isoler les ressources selon leur niveau de criticité.

### 2.1. Classification des Zones de Confiance (Tiering)

|Tier|Nom de la Zone|VLANs associés|Niveau de Risque|Description|
|---|---|---|---|---|
|**Tier 0**|**Cœur d'Identité**|200, 210, 220|**Critique**|Contrôleurs de domaine (AD-01/02) et Management. La compromission de cette zone signifie la perte de contrôle totale de l'entreprise.|
|**Tier 1**|**Données & Services**|230, 240, 500|**Élevé**|Serveur de fichiers, Sauvegardes et DMZ. Contient le patrimoine informationnel d'EcoTech.|
|**Tier 2**|**Accès Utilisateurs**|600 à 800|**Moyen**|Postes de travail (RH, Dev, Com) et Téléphonie. Zone la plus exposée aux menaces (phishing, web).|

### 2.2. Focus sur les Actifs Stratégiques

Certains segments bénéficient d'un durcissement (hardening) renforcé en raison de leur fonction :

#### A. Le Sanctuaire de l'Identité (VLAN 220)

- **Actifs :** **AD-01 (Core)** et **AD-02 (GUI)**.
- **Protection :** Aucun accès direct à Internet. Seul le flux DNS est autorisé vers le pfSense. L'utilisation de **Windows Server Core** pour le second contrôleur réduit la surface d'attaque de 60% en éliminant les composants inutiles (Internet Explorer, Explorateur de fichiers, etc.).

#### B. La Zone de Sauvegarde Isolée (VLAN 250)

- **Actif :** Stockage Bareos.
- **Protection :** Ce segment est **non-routé**. Il n'existe aucune passerelle (Gateway) vers ce VLAN. La communication est purement de Niveau 2 (L2) entre le serveur Bareos et sa baie de stockage, rendant le vol de données ou le chiffrement par ransomware techniquement impossible depuis le réseau utilisateur.

#### C. La DMZ et les Services de Bordure (VLAN 500)

- **Actif :** Proxy filtrant et Serveur Web.
- **Protection :** Zone tampon isolée par le pfSense. Tout serveur en DMZ est considéré comme potentiellement compromis ; ils n'ont donc aucun droit d'initier des connexions vers les réseaux internes (**Zones P, S, U**).

### 2.3. Sécurité de la Téléphonie IP (VLAN 670)

Suite à l'analyse de l'inventaire (**243 terminaux**), la VoIP est isolée dans son propre segment en **/23**.

- **Isolation :** Les flux SIP (Signalisation) et RTP (Voix) sont confinés au VLAN 670.
- **Filtrage :** Seul le serveur FreePBX est autorisé à communiquer avec l'extérieur (SIP Trunk) via des règles strictes sur le pare-feu pfSense.

## 3. Politiques d’accès (Administrateurs / Utilisateurs)

La gestion des accès chez EcoTech Solutions repose sur la séparation stricte des privilèges et l'isolation des flux d'administration.

### 3.1. Accès des Administrateurs (Tier 0 & 1)

L'administration du SI ne s'effectue jamais avec un compte utilisateur standard ni depuis un poste de travail classique.

- **Comptes Dédiés :** Les administrateurs possèdent au moins deux comptes :
    - Un compte standard (ex: **jedupont**) pour les tâches quotidiennes (mails, bureautique).
    - Un compte "Admin" (ex: **GX-P-jedupont**) utilisé exclusivement pour la gestion des serveurs.
- **Postes d'Administration (PAW - Privileged Access Workstation) :** Toutes les tâches d'administration (AD, VyOS, Proxmox) doivent être initiées depuis le **VLAN 210**.
    - L'accès RDP ou SSH vers les serveurs du **Tier 0 (VLAN 220)** est interdit depuis n'importe quel autre VLAN.
- **Gestion du serveur Core :** L'administration de l'AD-02 s'effectue exclusivement à distance via les outils RSAT (Remote Server Administration Tools) ou PowerShell depuis le VLAN 210, évitant ainsi toute ouverture de session locale ou RDP sur ce contrôleur de domaine.
- **Zéro Navigation Web :** La navigation sur Internet est strictement interdite sur les comptes et serveurs d'administration pour éviter le téléchargement de malwares ou le vol de jetons de session.

### 3.2. Accès des Utilisateurs (Tier 2)

Les 251 collaborateurs accèdent aux ressources selon leur appartenance de service ( segmentation par VLAN).

- **Privilèges Locaux :** Aucun utilisateur ne possède de droits "Administrateur" sur son poste de travail. Les installations de logiciels sont gérées de manière centralisée (via GPO ou déploiement).
- **Accès aux Partages (SMB) :** L'accès au serveur de fichiers (**VLAN 230**) est filtré par des groupes de sécurité AD.
    - Les utilisateurs du Wi-Fi (**VLAN 800**) n'ont pas accès aux partages de fichiers (lecture seule ou blocage complet selon le profil) pour limiter les risques en cas de perte de terminal mobile.
- **Isolation Inter-Services :** Par défaut, un utilisateur du Pôle Développement (**VLAN 660**) ne peut pas accéder aux ressources du VLAN Direction (**VLAN 600**).

### 3.3. Accès Distants (VPN et Partenaires)

Pour les sites de Nantes, Paris et les collaborateurs nomades, l'accès est sécurisé via le **VLAN 510**.

- **Tunnel Chiffré :** Utilisation d'un VPN SSL/TLS terminé sur le pare-feu **pfSense**.
- **Authentification Forte :** L'accès VPN requiert une double validation : Identifiant AD + certificat ou MFA (Multi-Factor Authentication).
- **Filtrage à l'entrée :** Une fois connecté, l'utilisateur VPN est restreint aux seuls services nécessaires (ex: accès au serveur de fichiers 230 via port 445), sans visibilité sur le reste de l'infrastructure.

### 3.4. Politique de Mots de Passe et Authentification

Appliquée via GPO (Group Policy Objects) sur le domaine `ecotech.local` :

|Paramètre|Valeur (Standard)|Valeur (Admin - Tier 0)|
|---|---|---|
|**Longueur minimale**|12 caractères|15 caractères|
|**Complexité**|Requise (Maj/Min/Chiffre/Spécial)|Requise (Élevée)|
|**Historique**|10 derniers interdits|24 derniers interdits|
|**Verrouillage**|5 tentatives infructueuses|3 tentatives infructueuses|
|**MFA**|Recommandé (VPN/Web)|**Obligatoire**|

## 4. Journalisation et Monitoring

La visibilité sur l'état du système est assurée par une collecte centralisée des logs, permettant une corrélation des événements entre les différentes couches de l'infrastructure (Réseau, Système, Application).

### 4.1. Centralisation des Événements (Syslog & SIEM)

Pour éviter la perte de traces en cas de compromission d'un serveur, les logs sont déportés en temps réel vers un serveur de gestion de logs centralisé situé dans le **VLAN 210** (Management).

La résolution DNS inverse est configurée sur l'ensemble des segments pour garantir que chaque adresse IP apparaissant dans les journaux soit automatiquement associée à un nom d'hôte unique, facilitant ainsi l'identification immédiate des machines lors d'un incident.

- **Serveurs Windows (AD-01 / AD-02 Core) :** Utilisation du service _Windows Event Forwarding_ (WEF) ou d'un agent léger pour exporter les journaux d'événements vers la sonde de supervision.
- **Équipements Réseau (pfSense / VyOS) :** Configuration du protocole **Syslog** pour l'envoi des logs de pare-feu et de routage.
- **Hyperviseur (Proxmox) :** Journalisation des accès à l'interface de gestion et des mouvements de machines virtuelles.

### 4.2. Événements Audités Prioritaires

Nous appliquons une politique d'audit sélective pour ne pas saturer le stockage tout en conservant les traces critiques :

|Source|Événements surveillés|Criticité|Justification|
|---|---|---|---|
|**Active Directory**|Échecs de connexion, création de comptes, modifications de groupes (Admin).|**Critique**|Détection de brute-force ou d'élévation de privilèges.|
|**pfSense**|Blocages sur le WAN, connexions VPN (réussies/échouées).|**Haute**|Surveillance des tentatives d'intrusion externe.|
|**Serveur de Fichiers**|Accès refusés sur des dossiers sensibles (RH/Direction).|**Moyenne**|Détection de tentatives de fuite de données internes.|
|**VyOS**|Modifications de la table de routage et des ACLs.|**Haute**|Intégrité de la segmentation réseau.|
|**FreePBX**|Tentatives de connexion au Trunk SIP (Appels externes).|**Haute**|Prévention de la fraude téléphonique (Phreaking).|

### 4.3. Rétention et Intégrité des Données

Conformément aux recommandations de la CNIL et du RGPD :

- **Durée de conservation :** Les logs de connexion sont conservés **6 mois à 1 an** pour répondre aux réquisitions judiciaires.
- **Intégrité :** Les archives de logs sont stockées sur une partition en lecture seule ou exportées vers le **VLAN 250** (Stockage Isolé) pour éviter toute modification par un attaquant cherchant à effacer ses traces.
- **Horodatage (NTP) :** La cohérence temporelle est assurée par une cascade NTP. Le pare-feu pfSense sert de source de temps de référence pour le cœur de réseau (VyOS et AD-01). Le contrôleur de domaine AD-01 redistribue ensuite cette heure précise à l'ensemble des 251 terminaux et serveurs via les services de domaine, garantissant une chronologie exacte des logs en cas d'analyse post-incident.

### 4.4. Supervision et Alerting (Zabbix / SNMP)

En complément des logs, une sonde de supervision (type Zabbix) monitore la santé des actifs en temps réel.

- **Alertes Critiques :** Envoi immédiat d'une notification (Email/Dashboard) en cas de :
    - Arrêt d'un contrôleur de domaine (**AD-01** ou **AD-02**).
    - Saturation d'un pool DHCP (notamment le **VLAN 670** et ses 243 téléphones).
    - Échec d'une sauvegarde Bareos (**VLAN 240**).
- **Seuils de performance :** Surveillance CPU/RAM sur Proxmox pour anticiper le besoin de ressources lié à la croissance d'EcoTech.

## 5. Sauvegardes et Continuité d'Activité

La stratégie de sauvegarde d'EcoTech repose sur le principe de **l'immuabilité et de l'isolation**, garantissant que même en cas de compromission totale du réseau utilisateur, les données vitales restent récupérables.

### 5.1. La Règle d'Or : Stratégie 3-2-1

EcoTech applique la règle de référence du secteur pour maximiser les chances de survie des données :

- **3 copies des données** : L'originale (production) + deux copies de sauvegarde.
- **2 supports différents** : Stockage sur disque (baie dédiée) et externalisation (Cloud ou bande théorique).
- **1 copie hors-site** : Externalisation des données vers le site de secours via le tunnel VPN.

### 5.2. Architecture Technique (Bareos)

Le service est orchestré par le serveur **Bareos (10.20.40.5)** situé dans le **VLAN 240**.

- **Agents de sauvegarde** : Chaque serveur critique (AD-01, AD-02, Serveur de fichiers) possède un agent Bareos-File-Daemon qui communique avec le serveur de sauvegarde via le port **TCP 9102**.
- **Centralisation** : Les flux de sauvegarde sont initiés par le serveur de sauvegarde ("Pull") et non par les clients, empêchant un client infecté de "pousser" des fichiers corrompus ou de supprimer ses propres sauvegardes.

### 5.3. Isolation Critique : Le VLAN 250 (Air-Gap Logiciel)

C'est la mesure de sécurité la plus forte de l'infrastructure :

- **Segment non-routé** : Le stockage des sauvegardes est situé dans le **VLAN 250**. Ce VLAN n'a **aucune passerelle par défaut**.
- **Impossibilité de rebond** : Un attaquant ayant pris le contrôle d'un poste dans le VLAN Dev (660) ou même du contrôleur de domaine ne peut techniquement pas "voir" ou atteindre la baie de stockage. La communication ne se fait qu'au niveau de la couche 2 entre le serveur Bareos et son stockage.
- **Impossibilité de rebond :** Le serveur Bareos dispose de deux interfaces réseau (NICs) distinctes. L'une pour communiquer avec les agents de sauvegarde (VLAN 240), l'autre, sans passerelle, dédiée au stockage (VLAN 250). Cette séparation physique virtuelle empêche tout attaquant de remonter jusqu'au stockage même en cas de compromission du serveur de sauvegarde.

### 5.4. Politique de Sauvegarde et Rétention

Pour équilibrer performance et sécurité, les sauvegardes suivent un cycle régulier :

|Type de Donnée|Fréquence|Rétention|Justification|
|---|---|---|---|
|**Active Directory**|Quotidienne (Full)|30 jours|Restauration rapide des objets AD.|
|**Serveur Fichiers**|Incrémentale (J) / Full (Sem)|90 jours|Protection du patrimoine métier.|
|**Configs VyOS/pfSense**|À chaque modification|1 an|Reconstruction rapide du réseau.|
|**Base VoIP (FreePBX)**|Hebdomadaire|30 jours|Historique des appels et annuaires.|

### 5.5. Test de Restauration et Plan de Reprise (PRA)

Une sauvegarde n'a de valeur que si elle est restaurable.

- **Vérification** : Un test de restauration complet est effectué chaque mois dans le **VLAN 630 (Développement)** pour valider l'intégrité des fichiers.
- **Objectifs (RTO/RPO)** :
    - **RPO (Perte de données maximale)** : 24 heures.
    - **RTO (Temps de remise en service)** : 4 heures pour les services critiques (Identité/Réseau).
