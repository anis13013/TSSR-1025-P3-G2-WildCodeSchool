Ce document définit les limites techniques et fonctionnelles du projet "Build Your Infra". Il permet de clarifier les responsabilités de l'équipe de maîtrise d'œuvre (4 administrateurs) et les livrables attendus.

## 1. Éléments inclus dans le projet (In-Scope)

Le périmètre inclut la conception, l'installation, la configuration et la documentation des briques suivantes :

### 1.1. Infrastructure de Virtualisation

- **Déploiement du socle Proxmox VE** : Installation et durcissement de l'hyperviseur.
- **Gestion du stockage** : Configuration des volumes pour les machines virtuelles (VM) et les conteneurs (LXC).
- **Création des instances** : Déploiement des serveurs (**EX**), des postes d'administration (**GX**) et des postes clients types (**BX/CX**).

### 1.2. Réseau et Sécurité Périmétrique

- **Cœur de réseau pfSense** : Configuration du routage inter-VLAN et des règles de pare-feu.
- **Segmentation (VLANs)** : Mise en œuvre des 20 segments réseau identifiés dans le plan d'adressage.
- **Services réseaux critiques** : Configuration du NAT, des services DHCP (relais ou serveur) et du filtrage de contenu.
- **Accès distants (VPN)** : Mise en place d'une solution de VPN (OpenVPN ou WireGuard) pour les sites de **Nantes** et **Paris** ainsi que pour les commerciaux nomades.

### 1.3. Services d'Identité et de Configuration

- **Annuaire Active Directory** : Installation de la forêt `ecotech.local` et des contrôleurs de domaine.
- **Gestion des objets** : Importation et organisation des 251 utilisateurs (CSV) dans les OUs respectives.
- **Stratégies de groupe (GPO)** : Déploiement des politiques de sécurité, de configuration des postes et de montage des lecteurs réseaux.

### 1.4. Services Applicatifs et MCO

- **Gestion de parc (GLPI)** : Installation du serveur et déploiement des agents d'inventaire sur les postes cibles.
- **Supervision** : Mise en place d'un tableau de bord de surveillance pour l'infrastructure.
- **Sauvegarde** : Configuration d'une solution de sauvegarde (Proxmox Backup Server ou équivalent) avec politique de rétention.
- **Serveur de fichiers** : Mise en œuvre des partages de données avec gestion fine des permissions (ACLs) pour les 7 départements.

### 1.5. Documentation Technique

- **HLD / LLD** : Rédaction des dossiers de conception (Architecture).
- **DEX (Dossier d'Exploitation)** : Rédaction des procédures de maintenance et d'administration quotidienne.

## 2. Éléments explicitement exclus (Out-of-Scope)

Les éléments suivants ne font pas partie des livrables de ce projet et ne seront pas pris en charge par l'équipe d'administration système et réseau :

### 2.1. Maintenance matérielle physique

- **Réparation des équipements** : Le dépannage physique des serveurs hôtes, des commutateurs (switches) physiques ou des onduleurs en cas de panne matérielle.
- **Maintenance des postes de travail** : Le remplacement des composants défectueux (écrans, claviers, batteries de PC portables) pour les 251 collaborateurs.
- **Câblage** : La pose ou le brassage de nouvelles prises RJ45 dans les locaux de Bordeaux, Nantes ou Paris.

### 2.2. Fourniture de la connectivité WAN

- **Abonnements Internet** : La souscription et la gestion des contrats auprès des Fournisseurs d'Accès Internet (FAI).
- **Garantie de Temps de Rétablissement (GTR)** : La responsabilité en cas de coupure de la liaison fibre optique extérieure.

### 2.3. Support applicatif métier spécifique

- **Développement logiciel** : Le support lié au code source, aux bugs applicatifs ou aux environnements de développement spécifiques des 116 collaborateurs du pôle D02.
- **Logiciels métiers** : L'assistance fonctionnelle sur les logiciels spécialisés de comptabilité (D07) ou de design graphique (D03).

### 2.4. Création de contenu et données

- **Saisie de données** : Le transfert manuel des dossiers RH ou financiers vers les nouveaux partages.
- **Communication** : La création des supports visuels ou des messages de communication interne.

### 2.5. Terminaux Mobiles (Mobilité hors PC)

- **Flotte mobile** : La gestion des abonnements téléphoniques et le support technique sur les smartphones (iOS/Android) des commerciaux, sauf pour la configuration de l'accès VPN.

## 3. Périmètre réseau couvert

Le réseau constitue la colonne vertébrale de l'infrastructure. Le projet couvre l'intégralité de la configuration logique et du routage pour les trois sites géographiques.

### 3.1. Segmentation logique (VLANs)

L'architecture réseau inclut la création et la configuration de **11 segments réseau (VLANs)** basés sur la norme **IEEE 802.1Q**. Cette segmentation permet d'isoler les flux par département et par niveau de sensibilité :

- **VLANs Métiers** : Segmentation pour les 7 départements (Développement, RH, Finance, etc.).
- **VLANs d'Infrastructure** : Segments dédiés aux serveurs (AD, Web, App), à l'administration (GX) et au management de l'hyperviseur.
- **VLANs Spécifiques** : Zones isolées pour les services de bordure (DMZ) et les flux de services (Printers, VoIP).

### 3.2. Routage et Filtrage (Firewalling)

- **Routage Inter-VLAN** : Configuration du pare-feu pfSense comme passerelle par défaut pour l'ensemble des segments.
- **Politiques de filtrage (ACLs)** : Mise en œuvre de règles de pare-feu strictes autorisant uniquement les flux nécessaires (ex: DNS, LDAP, SMB) et interdisant les communications non justifiées entre les départements sensibles (ex: Dev vers Finance).
- **Gestion du WAN** : Configuration du NAT (Network Address Translation) pour l'accès internet sécurisé des 251 collaborateurs.

### 3.3. Interconnexion des sites distants

Afin d'intégrer les compétences extérieures de **Nantes (UBIHard)** et **Paris (Studio Dlight)** :

- **Tunnels VPN** : Mise en place de passerelles sécurisées (OpenVPN ou WireGuard) pour relier les collaborateurs distants au LAN de Bordeaux.
- **Sécurisation des flux distants** : Application de politiques de filtrage spécifiques pour les accès provenant de l'extérieur, garantissant que les partenaires n'accèdent qu'aux ressources autorisées.

### 3.4. Services Réseau de base (Core Services)

- **Adressage IP** : Gestion du plan d'adressage statique pour les serveurs et mise en œuvre de l'adressage dynamique (DHCP) pour les 251 postes clients.
- **Résolution de noms** : Configuration des zones DNS directes et inverses, essentielles au bon fonctionnement du domaine Active Directory.

## 4. Périmètre temporel (par sprint)

Le projet s'inscrit dans une méthodologie Agile répartie sur 10 semaines. Chaque sprint possède des objectifs techniques et documentaires précis, validés par des jalons de livraison.

|Sprint|Durée|Dates (2026)|Objectifs Majeurs|
|---|---|---|---|
|**S01**|1 semaine|12/01 — 16/01|**Analyse et planification** : Étude du besoin, rédaction du HLD (Context, Scope, Network) et définition de la nomenclature.|
|**S02**|2 semaines|19/01 — 30/01|**Centralisation et sécurité périmétrique** : Installation de Proxmox, pfSense et déploiement de l'Active Directory.|
|**S03**|2 semaines|02/02 — 13/02|**Supervision et Backup** : Mise en œuvre des solutions de surveillance et stratégie de sauvegarde/restauration.|
|**S04**|2 semaines|16/02 — 27/02|**Déploiement et services** : Serveurs de fichiers, accès VPN pour Nantes/Paris et intégration des agents GLPI.|
|**S05**|2 semaines|02/03 — 13/03|**Audit de sécurité** : Tests d'intrusion internes, vérification du Tiering et durcissement final des configurations.|
|**S06**|1 semaine|16/03 — 20/03|**Rendu de projet** : Finalisation du DEX, revue finale de la documentation et soutenance.|

### 4.1. Jalons et Livrables

- **Fin de S01** : Validation de la conception globale (Dossier Architecture / HLD).
- **Fin de S04** : Infrastructure totalement opérationnelle pour les 251 collaborateurs.
- **Fin de S06** : Remise du dossier documentaire complet (HLD, LLD, DEX).

### 4.2. Gouvernance et Rôles

Le projet est porté par une équipe de 4 administrateurs (Anis, Frederick, Romain, Nicolas). Pour garantir l'agilité et la polyvalence, les rôles de **Product Owner** et de **Scrum Master** sont tournants à chaque début de sprint.

## 5. Hypothèses de responsabilité (RACI)

Pour assurer la réussite du projet et la pérennité de l'infrastructure, les responsabilités sont réparties entre l'équipe d'administration, le client EcoTech Solutions et les prestataires externes.

### 5.1. Responsabilités de l'Équipe Projet (Les 4 Administrateurs)

L'équipe projet est responsable de la **conception** et de la **réalisation** technique :

- **Concevoir l'architecture** : Garantir la cohérence du plan d'adressage, de la segmentation VLAN et du modèle de sécurité (Tiering).
- **Déploiement technique** : Installer et configurer les systèmes (Proxmox, pfSense, Windows Server, Debian) selon les règles de l'art.
- **Sécurisation** : Mettre en œuvre les politiques de filtrage, les accès VPN et la stratégie de sauvegarde.
- **Livrables documentaires** : Fournir une documentation complète (HLD, LLD) et un Dossier d'Exploitation (DEX) permettant la reprise en main par le support interne.

### 5.2. Responsabilités du Client (EcoTech Solutions)

Le client est responsable des **données** et des **moyens** :

- **Fourniture des données sources** : Mise à disposition des fichiers collaborateurs (CSV) à jour et définition des droits d'accès métiers.
- **Validation des jalons** : Présence aux revues de fin de sprint pour valider la conformité des services déployés.
- **Matériel hôte** : Fourniture du serveur physique destiné à accueillir l'hyperviseur Proxmox et garantie de son alimentation électrique.

### 5.3. Responsabilités des Partenaires Distants (Nantes / Paris)

Les entités **UBIHard** et **Studio Dlight** sont responsables de leur propre accès local :

- **Postes de travail** : Maintenance de leurs machines physiques locales avant connexion au VPN.
- **Connexion Internet locale** : Qualité et disponibilité de la connexion internet sur leurs sites respectifs pour permettre le montage des tunnels VPN vers Bordeaux.

### 5.4. Responsabilités des Prestataires Externes

- **Fournisseur d'Accès (FAI)** : Responsabilité limitée à la livraison du signal internet jusqu'au point de terminaison (Box/Routeur opérateur).
- **Éditeurs de logiciels** : Fourniture des mises à jour de sécurité et correctifs pour les systèmes d'exploitation (Microsoft, Debian, pfSense).

### Synthèse des Livrables du Scope

|Livrable|État|Format|
|---|---|---|
|**Dossier de Conception (HLD)**|Inclus|Markdown / PDF|
|**Infrastructure Opérationnelle**|Inclus|Environnement Proxmox|
|**Dossier d'Exploitation (DEX)**|Inclus|Markdown / PDF|
|**Maintenance Matérielle**|**Exclu**|Contrat Tiers|
