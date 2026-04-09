Ce document détaille l'environnement dans lequel s'inscrit le projet, les contraintes métier du client et les objectifs pédagogiques liés à la formation.

## 1. Contexte du Projet

### 1.1. Contexte Métier (EcoTech Solutions)

**EcoTech Solutions** est une entreprise innovante basée à Bordeaux, spécialisée dans les technologies de transition écologique. En raison d'un succès commercial récent et d'une croissance organique rapide, la société a vu ses effectifs atteindre **251 collaborateurs**.  

L'infrastructure actuelle est devenue un frein à la productivité et présente des risques de sécurité majeurs. Le projet vise à construire un nouvel environnement numérique capable de supporter :

- **La population active** : 251 utilisateurs répartis sur 7 pôles métiers (Direction, RH, Développement, Finance, etc.).
- **La densité technique** : Le pôle "Développement" représente à lui seul près de la moitié des effectifs (116 personnes), nécessitant des ressources serveurs et réseau performantes.
- **L'exigence de sécurité** : En tant qu'acteur technologique, EcoTech doit protéger ses données sensibles et garantir une disponibilité maximale de ses services.

### 1.2. Contexte Pédagogique (Projet "Build Your Infra")

Ce déploiement s'inscrit dans le cadre du titre professionnel **TSSR (Technicien Supérieur Systèmes et Réseaux)**. Le projet "Build Your Infra" est une mise en situation réelle visant à valider les compétences de l'équipe d'administration (4 personnes) sur l'ensemble du cycle de vie d'une infrastructure :

- **Ingénierie de conception** : Élaboration des documents HLD et LLD.
- **Mise en œuvre technique** : Déploiement d'un hyperviseur (Proxmox), de solutions réseaux (pfSense) et de services d'identité (Active Directory).
- **Application de standards professionnels** : Respect rigoureux des recommandations de l'**ANSSI** (modèle de Tiering), mise en place d'une nomenclature stricte et automatisation des déploiements.
- **Documentation et Transmission** : Rédaction d'un dossier d'architecture technique (DAT) et d'un dossier d'exploitation (DEX) permettant la passation du système.

## 2. Présentation de l'Entreprise et des Entités

### 2.1. Analyse Multi-Sociétés et Multi-Sites

L'infrastructure d'EcoTech Solutions doit supporter un écosystème complexe composé de l'entité principale et de partenaires stratégiques apportant des compétences extérieures. Cette diversité géographique impose des contraintes de connectivité et de sécurité inter-sites.

|Société|Effectif|Localisation|Rôle / Type|
|---|---|---|---|
|**EcoTech Solutions**|243|**Bordeaux (33)**|Siège social et cœur de l'activité.|
|**UBIHard**|6|**Nantes (44)**|Partenaire / Compétences extérieures.|
|**Studio Dlight**|2|**Paris (75)**|Partenaire / Compétences extérieures.|
|**Équipe Admin SI**|4|Bordeaux|Maîtrise d'œuvre.|

**Total des identités à gérer : 255.**

### 2.2. Intégration des Compétences Extérieures

Conformément à l'**Annexe 2**, EcoTech Solutions s'appuie sur des expertises distantes (Nantes et Paris). Bien que ces collaborateurs soient rattachés à des entités juridiques distinctes (UBIHard et Studio Dlight), ils sont pleinement intégrés aux flux de production, notamment pour le pôle Développement et Communication.

Cette organisation implique :

- **Une connectivité distante permanente** : Mise en œuvre d'accès sécurisés (VPN) pour permettre aux sites de Nantes et Paris d'accéder aux ressources hébergées à Bordeaux.
- **Une gestion unifiée mais cloisonnée** : Les comptes de ces sociétés tierces doivent être présents dans l'annuaire Active Directory tout en étant restreints à leurs périmètres de projets respectifs.

### 2.3. Répartition par Départements

Le regroupement fonctionnel des collaborateurs, toutes sociétés confondues, met en lumière la prédominance des métiers techniques :

- **Département Développement (D02)** : **116 collaborateurs** (moteur principal de l'activité, incluant les compétences de Nantes).
- **Département Communication (D03)** : **38 collaborateurs** (incluant les compétences de Paris).
- **Autres Départements métiers** : **97 collaborateurs** (Direction, RH, Finance, SAV, DSI).

| **Département**                       | **Code OU** | **Effectif** | **Enjeux Techniques**                                 |
| ------------------------------------- | ----------- | ------------ | ----------------------------------------------------- |
| **Développement**                     | **D02**     | 116          | **Pôle critique** (Bordeaux/Nantes). Flux importants. |
| **Service Commercial**                | **D05**     | 42           | Mobilité élevée et besoins VPN.                       |
| **Communication**                     | **D03**     | 38           | Stockage volumineux (Design/Vidéo - Paris).           |
| **Direction des Ressources Humaines** | **D01**     | 24           | Confidentialité et intégrité des données.             |
| **Finance et Comptabilité**           | **D07**     | 16           | Sécurité bancaire et archivage légal.                 |
| **DSI**                               | **-**       | 9            | Techniciens support et exploitation.                  |
| **Direction**                         | **D04**     | 6            | Accès privilégiés et disponibilité critique.          |

### 2.4. Analyse de l'Intégration Géographique

La présence de collaborateurs à **Nantes (UBIHard)** et **Paris (Studio Dlight)**, spécialisés respectivement dans le Développement et la Communication, fait de la connectivité inter-sites un besoin vital.

- **Besoins de connectivité** : Les partenaires distants doivent accéder aux serveurs de fichiers et aux outils de développement hébergés à Bordeaux comme s'ils étaient sur site.
- **Contrainte de Sécurité** : L'infrastructure doit être capable de différencier les flux provenant de ces "compétences extérieures" pour limiter leur accès aux seuls segments de projets autorisés.

## 3. Besoins fonctionnels principaux

Pour répondre aux enjeux de croissance et de sécurité d'EcoTech Solutions et de ses partenaires, l'infrastructure doit assurer les fonctions suivantes :

### 3.1. Gestion centralisée des accès (SSO)

Le besoin premier est l'unification de l'authentification pour les **255 identités**.

- **Session unique** : Un collaborateur doit pouvoir se connecter à son poste, à ses fichiers et aux applications avec un identifiant unique, quel que soit son département ou sa société d'appartenance.
- **Gestion du cycle de vie** : Faciliter l'arrivée (onboarding) et le départ (offboarding) des collaborateurs via une console d'administration centrale.

### 3.2. Collaboration et Partage de fichiers

L'infrastructure doit fournir un espace de stockage structuré et sécurisé :

- **Espaces départementaux** : Lecteurs réseaux dédiés à chaque département (RH, Finance, etc.) avec une étanchéité stricte.
- **Espaces inter-sociétés** : Zones d'échanges sécurisées pour permettre aux collaborateurs d'UBIHard (Nantes) et Studio Dlight (Paris) de travailler sur des projets communs avec les équipes de Bordeaux.

### 3.3. Connectivité Distante et Mobilité

Compte tenu de l'éparpillement géographique mentionné dans l'Annexe 2 :

- **Accès distant sécurisé** : Mise en place d'une solution de **VPN** performante pour les 8 collaborateurs distants (Nantes/Paris) et les 42 itinérants du **Service Commercial**.
- **Expérience utilisateur transparente** : Les utilisateurs distants doivent accéder aux ressources internes avec la même simplicité que s'ils étaient présents sur le site de Bordeaux.

### 3.4. Support et Gestion du parc (ITSM)

Afin de maintenir la productivité des 251 collaborateurs :

- **Portail de services** : Mise à disposition d'un outil de ticketing (**GLPI**) pour centraliser les demandes de support auprès des 9 techniciens de la DSI.
- **Inventaire automatisé** : Suivi précis du matériel et des logiciels installés sur les postes de travail (BX/CX) pour anticiper les besoins de renouvellement.

### 3.5. Environnement de production technique

Pour le département **Développement** (116 personnes), le besoin fonctionnel est critique :

- **Disponibilité des outils** : Accès permanent aux dépôts de code et aux serveurs de test.
- **Performance** : Temps de latence réduit pour les accès aux bases de données et aux ressources de compilation.

## 4. Besoins fonctionnels secondaires

Au-delà des services de base, l'infrastructure doit intégrer des fonctionnalités de gestion et de confort pour assurer une exploitation fluide sur le long terme.

### 4.1. Supervision et Alerting

L'équipe SI (4 administrateurs et 9 techniciens) doit disposer d'une visibilité complète sur l'état de santé du système.

- **Surveillance proactive** : Détecter les pannes de services (DNS, Web, AD) avant que les 116 développeurs ne soient impactés.
- **Alerting** : Notification immédiate en cas de saturation de stockage ou de charge anormale sur les hôtes Proxmox.

### 4.2. Sauvegarde et Résilience des données

Afin de protéger le patrimoine numérique d'EcoTech Solutions et de ses partenaires :

- **Restauration granulaire** : Capacité à récupérer un document précis effacé par erreur par un collaborateur des RH ou de la Finance.
- **Plan de continuité** : Garantir que les services critiques puissent redémarrer rapidement après un incident technique majeur.

### 4.3. Audit et Traçabilité

Pour répondre aux exigences de sécurité (Tiering) et de conformité :

- **Historique des accès** : Savoir qui a accédé aux données sensibles des départements RH et Finance.
- **Journalisation des modifications** : Tracer les changements effectués sur les politiques de sécurité (GPO) ou les règles de pare-feu.

### 4.4. Gestion des services d'impression et ressources partagées

- **Automatisation** : Les imprimantes doivent être connectées automatiquement sur les postes des utilisateurs en fonction de leur département (Bordeaux).
- **Simplicité** : Accès simplifié aux scanners et autres ressources matérielles communes.

### 4.5. Assistance à distance et Base de connaissances

Pour supporter les sites distants de **Nantes** (UBIHard) et **Paris** (Studio Dlight) :

- **Prise en main à distance** : Permettre aux techniciens de Bordeaux d'aider les collaborateurs distants sans déplacement physique.
- **Self-Service** : Mise à disposition de procédures simplifiées (ex: guide d'utilisation du VPN) via un portail documentaire pour réduire le nombre de tickets de support.

### 4.6. Gestion du cycle de vie des logiciels

- **Mises à jour centralisées** : S'assurer que les postes de travail (BX/CX) disposent toujours des derniers correctifs de sécurité sans intervention manuelle de l'utilisateur.

## 5. Public Cible

Ce document de contexte, ainsi que l'ensemble du dossier d'architecture (HLD), s'adresse aux parties prenantes suivantes :

### 5.1. Décideurs et Direction (EcoTech Solutions)

- **Objectif** : Valider que les solutions techniques proposées répondent aux enjeux métiers de croissance et de collaboration multi-sites (Bordeaux, Nantes, Paris).
- **Usage** : Compréhension globale du retour sur investissement technique et de la sécurisation du patrimoine informationnel de l'entreprise.

### 5.2. Équipe de Maîtrise d'Œuvre (Les 4 Administrateurs)

- **Objectif** : Maintenir une vision commune et cohérente de la conception tout au long des sprints de déploiement.
- **Usage** : Document de référence pour assurer l'alignement entre les besoins exprimés dans le CSV et les configurations techniques finales.

### 5.3. Équipe Technique et Support (Les 9 membres de la DSI)

- **Objectif** : Comprendre la logique de segmentation et les besoins spécifiques des départements (notamment le pôle Développement et les accès distants).
- **Usage** : Aide à la résolution d'incidents de niveau 1 et 2 et à l'accompagnement des 251 collaborateurs au quotidien.

### 5.4. Auditeurs et Experts Sécurité

- **Objectif** : Vérifier la conformité de l'architecture avec les contraintes de sécurité (modèle de Tiering) et de confidentialité (isolation des données RH/Finance).
- **Usage** : Analyse de la surface d'attaque et validation du cloisonnement inter-sociétés.  

### 5.5. Futurs Intervenants

- **Objectif** : Faciliter la passation de l'infrastructure ou l'intégration de nouveaux services
- **Usage** : Historique des choix architecturaux et compréhension des contraintes géographiques liées aux "compétences extérieures".
