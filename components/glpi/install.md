# Installation GLPI

## Prérequis vérifiés

Avant de lancer l’installation via le navigateur, on vérifie que les services de base fonctionnent correctement.

### 1. Statut du serveur web Apache

Le service Apache est actif et tourne depuis plusieurs minutes.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/install/40_glpi_install.png)  

Service actif – Apache HTTP Server 2.4

### 2. Statut de MariaDB (base de données)

Le serveur de base de données est lancé et prêt à recevoir les connexions.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/install/39_glpi_install.png)  

MariaDB 11.8.3 – service actif

## Étapes de l’installation via le navigateur

### 4. Message temporaire d’accès en écriture

GLPI demande un accès temporaire en écriture sur certains fichiers de configuration pendant l’installation.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/05_glpi_config.png)

Accès temporaire nécessaire pour config-db.php et glpicrypt.key

### 5. Choix de la langue

Sélection de la langue d’interface pour l’assistant d’installation.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/03_glpi_config.png)

Langue choisie : Français

### 6. Acceptation de la licence GNU GPL v3

Lecture et acceptation de la licence open-source.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/02_glpi_config.png)

GNU General Public License – Version 3, 29 juin 2007

Écran de licence avec bouton Continuer

### 7. Choix du type d’installation

Nouvelle installation ou mise à jour d’une version existante.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/04_glpi_config.png)

Option « Installer » sélectionnée

### 8. Vérification de la compatibilité (Étape 0)

GLPI teste l’environnement PHP et les extensions nécessaires.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/07_glpi_config.png)

Tous les tests obligatoires sont passés (curl, gd, intl, zlib, sodium, etc.)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/08_glpi_config.png)

Quelques avertissements de sécurité à traiter après l’installation

### 9. Test de connexion à la base de données (Étape 2)

Connexion réussie à MariaDB et sélection de la base.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/09_glpi_config.png)


Connexion validée – Base sélectionnée : glpidb

### 10. Initialisation de la base de données (Étape 3)

Création des tables et insertion des données de base.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/10_glpi_config.png)

Message de succès : « OK – La base a bien été initialisée »

## Après l’installation – Première connexion

### 11. Tableau de bord principal

Connexion avec le compte super-admin par défaut et affichage des alertes de sécurité.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d9d7b349eb4764d64be12e01f7ea0861301277ac/components/glpi/ressources/config/11_glpi_config.png)

Alertes importantes : changer les mots de passe par défaut, supprimer le dossier install/, sécuriser le dossier racine

## Actions critiques recommandées immédiatement après l’installation

- Supprimer le dossier d’installation pour des raisons de sécurité  

- Restreindre les droits en écriture sur le dossier config  

- Changer les mots de passe des comptes par défaut (glpi, post-only, tech, normal)  

- Mettre en place une synchronisation LDAP si besoin (voir document séparé)
