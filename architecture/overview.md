Ce document présente une vision globale de l'infrastructure informatique déployée pour le siège de Bordeaux. Il détaille les objectifs, la structure logique et les composants clés du système.

## 1. Résumé et Objectifs Globaux du Projet

### 1.1. Résumé du projet

Le projet **"Build Your Infra"** consiste à concevoir et déployer l'architecture système et réseau complète de la société **EcoTech Solutions**, installée à Bordeaux.  
En pleine phase d'expansion, l'entreprise nécessite une infrastructure moderne, robuste et hautement disponible pour supporter les activités critiques de ses **251 collaborateurs**, répartis au sein de 7 départements métiers.  
  
La maîtrise d'œuvre, l'administration et la sécurisation de cet environnement sont confiées à une équipe dédiée de **4 administrateurs système et réseau**, garantissant un déploiement conforme aux meilleures pratiques du secteur.  

La solution technique est intégralement virtualisée sur un socle **Proxmox VE**. Elle combine l'agilité de solutions Open Source (pfSense pour la sécurité, Debian pour les services applicatifs) avec la puissance de l'écosystème Windows (Active Directory pour la gestion des identités).  
Cette approche permet de fournir un environnement de travail unifié, évolutif et strictement cloisonné, répondant aux enjeux de performance et de cybersécurité de la société.  

### 1.2. Objectifs Globaux

La réussite du déploiement repose sur l'atteinte des objectifs stratégiques et techniques suivants :

- **Gestion centralisée des identités et des ressources** : Mise en œuvre d'un domaine Active Directory unique (**ecotech.local**) pour assurer l'authentification et le contrôle d'accès des 251 collaborateurs, permettant une gestion industrielle des droits et des politiques de sécurité (GPO).  
- **Sécurisation par le cloisonnement (Modèle de Tiering)** : Application stricte des recommandations de l'ANSSI pour isoler les 9 comptes d'administration des usages standards. L'objectif est de garantir qu'une compromission sur un poste utilisateur ne puisse pas s'étendre aux privilèges d'administration du domaine.  
- **Segmentation réseau (VLANs)** : Mise en place d'un cœur de réseau pfSense pour étanchéifier les flux entre les 7 pôles métiers. Cette segmentation vise à limiter la surface d'attaque et à optimiser les performances réseau en isolant les domaines de diffusion.  
- **Standardisation et Documentation** : Application rigoureuse de la nomenclature définie (**naming.md**) à tous les objets (VM, utilisateurs, groupes, machines). Cette homogénéité est indispensable pour faciliter la maintenance, l'automatisation par scripts et l'audit du parc.  
- **Haute Évolutivité** : Dimensionnement de l'architecture pour supporter la densité critique du pôle Développement (116 collaborateurs) et permettre l'ajout de nouvelles ressources sans remise en cause de la structure globale.  
- **Maintien en Condition Opérationnelle (MCO)** : Garantie de la résilience de l'infrastructure via des solutions de sauvegarde performantes et une supervision proactive, assurant ainsi la continuité de service pour l'ensemble des métiers d'EcoTech Solutions.  

## 2. Schéma Global de l'Infrastructure

Le schéma ci-dessous illustre la segmentation réseau (VLANs) et le cœur de réseau (pfSense).  
## 3. Liste des briques techniques

L'architecture d'EcoTech Solutions repose sur une sélection de solutions logicielles stables et pérennes, articulées autour de quatre piliers technologiques majeurs.

### 3.1. Pilier Virtualisation

Ce socle assure l'abstraction matérielle et la gestion dynamique des ressources pour l'ensemble des serveurs et postes de travail virtuels.  

- **Système** : **Proxmox VE 8.x** (Hyperviseur de Type 1).  
- **Technologies clés** : KVM (Machines virtuelles), LXC (Conteneurs légers).  
- **Rôle** : Hébergement des instances **EX** (serveurs), **BX/CX** (postes clients) et **GX** (administration).  

### 3.2. Pilier Réseau et Sécurité

Ce pilier garantit l'étanchéité des flux entre les départements et la protection périmétrique de l'infrastructure.

- **Système** : **pfSense CE 2.7.x**.  
- **Protocoles et Standards** :
    - **IEEE 802.1Q** : Segmentation en 11 VLANs.
    - **OpenVPN / IPSec** : Accès distants sécurisés pour l'équipe SI.
    - **NAT / Outbound** : Gestion des accès internet.
- **Rôle** : Cœur de réseau, pare-feu filtrant et routage inter-VLAN.

### 3.3. Pilier Identité et Services "Core"

Il constitue le cerveau de l'infrastructure pour la gestion des 251 collaborateurs et des ressources réseau.

- **Système** : **Microsoft Windows Server 2022** (Rôle AD DS).
- **Protocoles et Services** :
    - **Active Directory** : Authentification Kerberos / NTLM.
    - **DNS / DHCP** : Résolution de noms et adressage dynamique.
    - **SMB / CIFS** : Partage de fichiers centralisé.
- **Rôle** : Annuaire centralisé, gestion des GPO et contrôle d'accès.
    

### 3.4. Pilier Gestion et MCO (Maintien en Condition Opérationnelle)

Ces outils assurent la visibilité, l'inventaire et la résilience de l'ensemble du système.

- **Logiciels** :
    - **GLPI 10.x** : Gestion du parc (ITSM) et inventaire.
    - **MariaDB 10.x (LTS)** : Gestionnaire de bases de données applicatives.
    - **Zabbix / Nagios** : Supervision proactive des hôtes et services.
    - **Proxmox Backup Server (PBS)** : Sauvegarde dédupliquée et restauration.
- **Protocoles** : SNMP (Supervision), SMTP (Alerting), HTTPS (Interfaces de gestion).

> **Note de traçabilité** : Les versions mineures exactes, les numéros de Builds et les détails des correctifs de sécurité sont consignés dans le document détaillé : **[components/software.md](/components/software.md)**.

## 4. Documentation HLD associée

Pour une compréhension détaillée de chaque sous-système, veuillez consulter les documents suivants :

- **[context.md](context.md)** : Analyse des besoins utilisateurs et contexte métier.
- **[scope.md](scope.md)** : Définition précise du périmètre technique (In-Scope/Out-of-Scope).
- **[network.md](network.md)** : Architecture réseau détaillée et flux de données.
- **[ip_configuration.md](ip_configuration.md)** : Plan d'adressage IP statique et plages DHCP.
- **[security.md](security.md)** : Stratégie de défense, Tiering et durcissement (Hardening).
- **[services.md](services.md)** : Détail du catalogue de services applicatifs.

Pour des informations relatives à l'implémentation physique, aux configurations logicielles exactes ou à l'exploitation quotidienne, veuillez vous référer aux autres racines documentaires :

- **Dossier [components/](./components/) (LLD)** : Détails techniques, matériel et fiches de configuration logicielle.
- **Dossier [operations/](./operations/) (DEX)** : Procédures de maintenance et d'exploitation.
- **Dossier [sprints/](./sprints/)** : Suivi chronologique et avancement du projet.
