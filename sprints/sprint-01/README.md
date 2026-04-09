<span id="haut-de-page"><span/>

## Table des matières

- [1. Objectifs du sprint](#1-objectifs-du-sprint)
- [2. Équipe et rôles](#2-équipe-et-rôles)
- [3. Finalité des objectifs](#3-finalité-des-objectifs)
- [4. Problèmes rencontrés](#4-problèmes-rencontrés)
- [5. Décisions techniques](#5-décisions-techniques)
- [6. Travail restant](#6-travail-restant)
- [7. Liens vers les livrables](#7-liens-vers-les-livrables)

## 1. Objectifs du sprint

| Type | Objectif | Description |
|------|----------|-------------|
| **Principal** | Analyse du sujet d'entreprise | Compréhension du contexte, des besoins et des contraintes de l'entreprise EcoTech Solutions |
| **Principal** | Création de l'arborescence Github de la documentation | Structuration complète des dossiers et fichiers markdown selon le modèle imposé |
| **Principal** | Tous les dossiers sont présents | Vérification de la présence de tous les dossiers requis (architecture, components, operations, sprints, etc.) |
| **Principal** | Tous les fichiers sont remplis | Rédaction initiale de tous les fichiers de documentation avec les informations disponibles |

## 2. Équipe et rôles

| Rôle | Membre | Responsabilités principales |
|------|--------|----------------------------|
| **Product Owner (PO)** | Anis BOUTALEB | Priorisation des tâches, interface avec le formateur, validation des livrables, rédaction context.md, scope.md |
| **Scrum Master (SM)** |  | Animation des réunions, suivi du backlog, coordination d'équipe, rédaction sprints/sprint-01/README.md, architecture/overview.md, security.md et services.md  |
| **Technicien** | Romain GENOUD | Rédaction network.md, ip_configuration.md et naming.md |
| **Technicien** | Nicolas JOUVEAUX | Rédaction hardware.md, software.md et des premiers services (active-directory/) |

## 3. Finalité des objectifs

À la fin du sprint, nous avons atteint les résultats suivants :

- **Analyse du sujet d'entreprise terminée** : Compréhension claire de l'entreprise EcoTech Solutions, ses besoins, son organisation et son existant.
- **Arborescence Github complète** : Tous les dossiers et sous-dossiers créés selon le modèle de documentation imposé.
- **Tous les fichiers de documentation remplis** :
  - Fichiers DAT : **README.md**, **naming.md**
  - Fichiers HLD : **overview.md**, **context.md**, **scope.md**, **network.md**, **ip_configuration.md**, **security.md**, **services.md**
  - Fichiers LLD : **hardware.md**, **software.md**
  - Fichiers DEX : **overview.md** (dans operations)
  - Fichier de suivi : **planning.md**
  - Dossier **sprints/sprint-01/** avec ce fichier README.md
- **Fichiers annexes intégrés** :
  - **p3-sprint-1-annexe-1-entreprise-1-EcoTechSolutions.md**
  - **p3-sprint-1-annexe-5-detailsDocumentation.md**
  - **p3-sprint-1-annexe-6-nomenclature.md**
  - **p3-sprint-1-annexe-7-suiviObjectifsDuProjet.md**
  - **p3-sprint-1-annexe-8-calculTemps.md**
  - **s01_EcoTechSolutions.md** (collaborateurs)

## 4. Problèmes rencontrés

| Problème | Impact | Solution apportée |
|----------|--------|-------------------|
| Attribution des plages IP et VLANs cohérente avec les besoins réels | Incohérences potentielles | Validation croisée entre **ip_configuration.md** et **network.md** par l'équipe technique |
| Répartition des tâches de rédaction | Risque de chevauchement ou d'omissions | Utilisation d'un tableau de répartition clair validé par le SM |

## 5. Décisions techniques

- Choix de la **vue par cycle de vie** pour l'organisation de la documentation.
- Adoption de la **nomenclature imposée** pour les noms de fichiers et dossiers.
- Utilisation du **markdown** avec images légendées et code formaté.
- Structuration des **VLANs par département** avec adressage logique et scalable.
- Validation systématique des documents par le PO avant commit.

## 6. Travail restant

- Finalisation des **schémas réseau** dans **network.md**.
- Complétion des **matrices de flux** dans **security.md**.
- Début de la **planification détaillée** dans **planning.md**.
- Révision et validation finale de tous les fichiers par le PO avant livraison.
- Préparation de la présentation de fin de sprint.

## 7. Liens vers les livrables

- [Fichier de suivi d'objectifs](../../planning.md)
- [Document DAT - README.md](../../README.md)
- [Architecture HLD - overview.md](../../architecture/overview.md)
- [Contexte métier - context.md](../../architecture/context.md)
- [Configuration IP - ip_configuration.md](../../architecture/ip_configuration.md)
- [Stratégie de sécurité - security.md](../../architecture/security.md)
- [Services déployés - services.md](../../architecture/services.md)
- [Liste des collaborateurs](../../s01_EcoTechSolutions.md)

[⬆️ Retour au début de la page ⬆️](#haut-de-page)
