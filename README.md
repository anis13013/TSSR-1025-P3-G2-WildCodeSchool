|![Logo EcoTech](/architecture/ressources/Logo_EcoTech.png)|
| --- |

## Présentation du projet (Introduction / contexte)

Ce projet s’inscrit dans le cadre de la formation **TSSR (Technicien Supérieur Systèmes et Réseaux)**.  
Il vise à concevoir, déployer et documenter une infrastructure réseau complète pour l’entreprise **EcoTech Solutions**, spécialisée dans les solutions IoT pour la gestion intelligente de l’énergie.

**Contexte initial :**  
L’infrastructure actuelle est rudimentaire :
- Réseau unique **172.16.20.0/24** géré par une box FAI
- Absence de domaine Active Directory
- Sécurité décentralisée, pas de politique centralisée
- Stockage et sauvegarde non structurés
- Pas de supervision ni gestion de parc

**Objectif pédagogique :**  
Mettre en pratique les compétences des CCP1 à CCP9 du REAC TSSR, en suivant une méthodologie projet agile et en respectant les bonnes pratiques d’architecture, de sécurité et de documentation.

## Objectifs finaux (Planification du projet)

Le projet s'étale sur 10 semaines, du 12 janvier au 20 mars 2026, selon le calendrier suivant :

|Sprint|Durée|Objectifs|
|---|---|---|
|**S01**|1 semaine|Analyse et planification|
|**S02**|2 semaines|Centralisation et sécurisation périmétrique|
|**S03**|2 semaines|Supervision et backup|
|**S04**|2 semaines|Déploiement et services|
|**S05**|2 semaines|Audit de sécurité|
|**S06**|1 semaine|Rendu de projet|

## L'Équipe Projet

Les rôles de **Product Owner** et **Scrum Master** sont tournants et définis par le formateur à chaque début de sprint.
## Vue d'ensemble des composants

L'infrastructure repose sur les briques technologiques suivantes :

- **Hyperviseur** : Proxmox VE pour la virtualisation des serveurs et postes clients.
- **Réseau et Sécurité** : Pare-feu pfSense pour le filtrage et la segmentation des flux.
- **Systèmes Serveurs** : Windows Server 2022 (versions Standard et Core) et serveurs Linux Debian.
- **Systèmes Clients** : Postes de travail sous Windows 10/11 et Ubuntu Desktop.

## Services déployés

Les services principaux mis en œuvre durant le projet sont :

- **Gestion d'identité** : Active Directory Domain Services (AD DS).
- **Services réseau** : DNS (Domain Name System) et DHCP (Dynamic Host Configuration Protocol).
- **Fichiers et Impression** : Serveurs de fichiers sécurisés et gestion des impressions.
- **Sécurité et Accès** : VPN pour le nomadisme, filtrage applicatif et audit.
- **Maintenance** : Solution de sauvegarde, restauration et outils de supervision.

## Où trouver la documentation ?

La documentation est organisée de manière hiérarchique :

- **naming.md** : Règles de nomenclature pour l'ensemble des objets de l'infrastructure.
- **architecture/** : Dossier contenant le **HLD** (conception globale et schémas réseaux).
- **components/** : Dossier contenant le **LLD** (détails techniques par brique de service).
- **operations/** : Dossier contenant le **DEX** (procédures d'exploitation et de maintenance).
- **sprints/** : Suivi chronologique de l'avancement et journal de bord.
