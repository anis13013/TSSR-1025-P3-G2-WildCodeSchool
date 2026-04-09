# Configuration Applicative de Guacamole

Ce document décrit la configuration applicative d'Apache Guacamole : gestion des utilisateurs, des groupes, des connexions et des permissions.

---

## Table des matières

  - [1. Première connexion et sécurisation](#1-première-connexion-et-sécurisation)
    - [1.1. Connexion initiale](#11-connexion-initiale)
    - [1.2. Changement du mot de passe administrateur](#12-changement-du-mot-de-passe-administrateur)
  - [2. Architecture des groupes et permissions](#2-architecture-des-groupes-et-permissions)
  - [3. Création des groupes de connexions](#3-création-des-groupes-de-connexions)
    - [3.1. Groupe "Windows"](#31-groupe-windows)
    - [3.2. Autres groupes selon infrastructure](#32-autres-groupes-selon-infrastructure)
  - [4. Création des groupes d'utilisateurs](#4-création-des-groupes-dutilisateurs)
    - [4.1. Groupe "Admins-Windows"](#41-groupe-admins-windows)
    - [4.2. Autres groupes selon besoins](#42-autres-groupes-selon-besoins)
  - [5. Configuration des connexions](#5-configuration-des-connexions)
    - [5.1. Connexion RDP vers le serveur Active Directory](#51-connexion-rdp-vers-le-serveur-active-directory)
    - [5.2. Connexion SSH vers un serveur Linux](#52-connexion-ssh-vers-un-serveur-linux)
    - [5.3. Protocole VNC (non configuré)](#53-protocole-vnc-non-configuré)
  - [6. Attribution des permissions](#6-attribution-des-permissions)
    - [6.1. Méthode 1 : Permissions sur les groupes de connexions](#61-méthode-1--permissions-sur-les-groupes-de-connexions)
    - [6.2. Méthode 2 : Permissions sur les connexions individuelles](#62-méthode-2--permissions-sur-les-connexions-individuelles)
  - [7. Création d'utilisateurs](#7-création-dutilisateurs)
    - [7.1. Utilisateur administrateur](#71-utilisateur-administrateur)
    - [7.2. Utilisateur standard](#72-utilisateur-standard)
  - [8. Tests de validation](#8-tests-de-validation)
    - [8.1. Test de connexion RDP](#81-test-de-connexion-rdp)
    - [8.2. Test de connexion SSH](#82-test-de-connexion-ssh)
    - [8.3. Test des permissions](#83-test-des-permissions)
  - [9. Architecture finale des permissions](#9-architecture-finale-des-permissions)

---

## 1. Première connexion et sécurisation

### 1.1. Connexion initiale

Accéder à `https://bastion.ecotech.local/guacamole`

**Identifiants par défaut :**
- Username : `guacadmin`
- Password : `guacadmin`

---

### 1.2. Changement du mot de passe administrateur

**⚠️ Sécurité critique :** Ne jamais laisser les identifiants par défaut en production.

1. Cliquer sur **guacadmin** (en haut à droite) → **Settings**
2. Menu de gauche : **Users**
3. Cliquer sur **guacadmin**
4. Section **Change Password** :
   - Old password : `guacadmin`
   - New password : `[Mot_de_passe_fort]`
   - Confirm password : `[Mot_de_passe_fort]`
5. Cliquer sur **Save**

**Déconnexion automatique.** Se reconnecter avec le nouveau mot de passe.

---

## 2. Architecture des groupes et permissions

Pour gérer efficacement les accès, une structure hiérarchique a été mise en place avec :
- **Groupes d'utilisateurs** : Définissent QUI peut accéder
- **Groupes de connexions** : Définissent À QUOI on peut accéder
- **Permissions** : Lient les deux ensemble

Cette approche suit le principe RBAC (Role-Based Access Control) couramment utilisé dans les environnements d'entreprise.

---

## 3. Création des groupes de connexions

Les groupes de connexions permettent d'organiser logiquement les serveurs par type ou fonction.

### 3.1. Groupe "Windows"

1. **Settings** → **Connection Groups**
2. **New Connection Group**
3. Remplir :
   - Group name : `Windows`
   - Type : `Organizational`
4. **Save**

---

### 3.2. Autres groupes selon infrastructure

Répéter le processus pour créer d'autres groupes selon les besoins :
- `Linux` : Serveurs Linux
- `Web` : Serveurs web
- `Bases de données` : Serveurs de bases de données
- Etc.

---

## 4. Création des groupes d'utilisateurs

Les groupes d'utilisateurs permettent d'attribuer des permissions à plusieurs utilisateurs simultanément.

### 4.1. Groupe "Admins-Windows"

1. **Settings** → **User Groups**
2. **New User Group**
3. Remplir :
   - Group name : `Admins-Windows`
4. **Permissions** : Laisser toutes les cases décochées (les permissions seront attribuées via les connexions)
5. **Save**

---

### 4.2. Autres groupes selon besoins

Créer d'autres groupes selon l'organisation :
- `Admins-Linux` : Administrateurs serveurs Linux
- `Admins-T0` : Administrateurs Tier 0 (privilèges maximaux)
- `Admins-T1` : Administrateurs Tier 1 (serveurs applicatifs)
- `Support` : Équipe de support utilisateurs

---

## 5. Configuration des connexions

### 5.1. Connexion RDP vers le serveur Active Directory

1. **Settings** → **Connections**
2. **New Connection**
3. **Edit Connection** :
   - Name : `ECO-BDX-EX01` (ou nom descriptif)
   - Location : `Windows`
   - Protocol : `RDP`

4. **Parameters → Network** :
   - Hostname : `10.20.20.5`
   - Port : `3389`

5. **Parameters → Authentication** :
   - Username : `Administrateur`
   - Password : `[Mot_de_passe_AD]`
   - Domain : `ECOTECH`
   - Security mode : `Any`
   - Ignore server certificate : ✅ Coché

6. **Save**

---

### 5.2. Connexion SSH vers un serveur Linux

1. **Settings** → **Connections**
2. **New Connection**
3. **Edit Connection** :
   - Name : `ECO-BDX-EX07` (ou nom descriptif)
   - Location : `Linux` (ou autre groupe)
   - Protocol : `SSH`

4. **Parameters → Network** :
   - Hostname : `10.20.20.7`
   - Port : `22` (ou port personnalisé comme 22222)

5. **Parameters → Authentication** :
   - Username : `root` ou utilisateur approprié
   - Password : `[Mot_de_passe]`

6. **Save**

**Note :** Les connexions SSH peuvent également utiliser l'authentification par clé privée au lieu du mot de passe pour une sécurité renforcée.

---

### 5.3. Protocole VNC (non configuré)

**Décision technique :**

Le protocole VNC (Virtual Network Computing) n'a pas été configuré sur le bastion pour les raisons suivantes :

**Analyse du besoin :**
- Les serveurs Windows sont administrés via RDP (protocole natif Microsoft, chiffré par TLS)
- Les serveurs Linux sont administrés en ligne de commande via SSH (protocole sécurisé)
- Aucun serveur de l'infrastructure ne nécessite d'accès graphique distant via VNC

**Justification :**
- Principe de simplicité : ne pas configurer de protocoles inutilisés
- Principe du moindre privilège : réduire la surface d'attaque
- VNC n'offre pas de chiffrement natif (contrairement à RDP et SSH)

**Évolution future :**

Si l'infrastructure devait accueillir des serveurs Linux avec interface graphique (ex: hyperviseurs Proxmox, outils de monitoring graphiques), VNC pourrait être activé en :
1. Créant une connexion VNC dans Guacamole (protocole VNC, port 5900)
2. Ajoutant une règle pfSense BASTION → Serveurs:5900-5910 (TCP)
3. Installant et sécurisant un serveur VNC (TigerVNC, TightVNC) sur les serveurs cibles

---

## 6. Attribution des permissions

### 6.1. Méthode 1 : Permissions sur les groupes de connexions

Cette méthode permet de donner accès à toutes les connexions d'un groupe en une seule opération.

1. **Settings** → **Connection Groups**
2. Cliquer sur le groupe (ex: `Windows`)
3. Onglet **Permissions**
4. Section **User Groups** :
   - Chercher `Admins-Windows`
   - Cocher **Read**
5. **Save**

**Résultat :** Tous les membres du groupe `Admins-Windows` peuvent maintenant accéder à toutes les connexions dans le groupe `Windows`.

---

### 6.2. Méthode 2 : Permissions sur les connexions individuelles

Pour un contrôle plus granulaire :

1. **Settings** → **Connections**
2. Cliquer sur une connexion
3. Onglet **Permissions**
4. Section **Users** ou **User Groups** :
   - Ajouter les utilisateurs/groupes autorisés
   - Cocher **Read**
5. **Save**

---

## 7. Création d'utilisateurs

### 7.1. Utilisateur administrateur

1. **Settings** → **Users**
2. **New User**
3. Remplir :
   - Username : `admin-infra` (ou nom approprié)
   - Password : `[Mot_de_passe_fort]`
4. **Permissions** : Cocher selon les besoins
   - Administer system : Pour les administrateurs complets
   - Create new connections : Pour permettre l'ajout de serveurs
5. Onglet **Groups** :
   - Member of : Ajouter aux groupes appropriés (ex: `Admins-Windows`)
6. **Save**

---

### 7.2. Utilisateur standard

Même processus, mais sans les permissions d'administration système.

**Exemple pour un technicien de support :**
1. **Settings** → **Users**
2. **New User**
3. Remplir :
   - Username : `technicien1`
   - Password : `[Mot_de_passe_fort]`
4. **Permissions** : Ne rien cocher (héritage des groupes uniquement)
5. Onglet **Groups** :
   - Member of : Ajouter au groupe `Support`
6. **Save**

---

## 8. Tests de validation

### 8.1. Test de connexion RDP

1. Depuis la page d'accueil de Guacamole
2. Cliquer sur une connexion RDP (ex: `ECO-BDX-EX01`)
3. Le bureau Windows devrait s'afficher dans le navigateur
4. Vérifier la fonctionnalité clavier/souris

---

### 8.2. Test de connexion SSH

1. Cliquer sur une connexion SSH (ex: `ECO-BDX-EX07`)
2. Un terminal devrait s'afficher
3. Tester quelques commandes

---

### 8.3. Test des permissions

1. Se déconnecter
2. Se connecter avec un utilisateur du groupe `Admins-Windows`
3. Vérifier qu'il ne voit que les connexions Windows
4. Vérifier qu'il ne peut pas accéder aux connexions d'autres groupes

---

## 9. Architecture finale des permissions

```
GROUPES D'UTILISATEURS
│
├─ Admins-Windows
│   └─ Accès : Groupe "Windows" (Read)
│       └─ Connexions visibles :
│           ├─ ECO-BDX-EX01 (AD Server RDP)
│           └─ [Autres serveurs Windows...]
│
├─ Admins-Linux
│   └─ Accès : Groupe "Linux" (Read)
│       └─ Connexions visibles :
│           ├─ ECO-BDX-EX07 (SSH)
│           └─ [Autres serveurs Linux...]
│
└─ Support
    └─ Accès : Groupe "Support" (Read)
        └─ Connexions visibles :
            └─ [Serveurs de support uniquement...]

FLUX DE PERMISSIONS :
Utilisateur → Membre de → Groupe d'utilisateurs → Accès à → Groupe de connexions → Contient → Connexions
```

---

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
