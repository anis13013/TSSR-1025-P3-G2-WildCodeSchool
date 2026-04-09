# Audit de sécurité sur le domaine ecotech.local

---

Audit du domaine `ecotech.local` réalisé avec l'outil PingCastle.
L'objectif est de scanner le domaine depuis le DC ECO-BDX-EX02, identifier les vulnérabilités du domaine, d'appliquer les corrections recommandées et de comparer les résultats obtenus.

---

## Table des matières

- [1. Audit avec PingCastle](#1-audit-avec-pingcastle)
- [2. Vulnérabilités Détectées](#2-vulnérabilités-détectées)
- [3. Outils utilisés](#3-outils-utilisés)

---

## 1. Audit avec PingCastle

| Audit N° | Score PingCastle | Contexte |
| --- | --- | --- |
| Audit N°1 | 60 / 100 | Découverte de l'outil |
| Audit N°2 | 82 / 100 | Début de l'audit |
| Audit N°3 | | Après corrections |

---

## 2. Vulnérabilités Détectées

PingCastle détecte les failles du domaine et les classe par ordre de gravité.
Plus le score est bas, plus le domaine est sécurisé. Plus le score d'une faille est élevé, plus elle est critique et prioritaire.

Le score global correspond au **maximum** des 4 indicateurs ci-dessous — un seul indicateur critique suffit à tirer le score vers le haut.

| Catégorie | Score |
| --- | --- |
| Anomalies | 82 / 100 |
| Privileged Accounts | 60 / 100 |
| Stale Objects | 38 / 100 |
| Trusts | 1 / 100 |

### Détail des vulnérabilités

| Catégorie | Vulnérabilité | Score | Statut |
| --- | --- | --- | --- |
| Anomalies | Dernière sauvegarde AD obsolète (49 jours) | +15 | À corriger |
| Anomalies | LAPS non installé | +15 | *Corrigé* |
| Anomalies | Politique de mot de passe inférieure à 8 caractères | +10 | *Corrigé* |
| Anomalies | Service Spooler accessible depuis un DC (PrintNightmare) | +10 | *Corrigé* |
| Anomalies | Audit policy des DCs insuffisante | +10 | À corriger |
| Anomalies | LDAP sans enforcement de signature | +5 | À corriger |
| Anomalies | Interface d'enrollment de certificats en HTTP | +5 | À corriger |
| Anomalies | Zone DNS avec transferts de zone activés | +5 | À corriger |
| Privileged Accounts | Compte Administrateur natif utilisé récemment | +20 | À corriger |
| Privileged Accounts | Comptes Admin sans flag "sensible et non délégable" (5) | +20 | *Corrigé* |
| Privileged Accounts | Groupe Schema Admins non vide | +10 | *Corrigé* |
| Privileged Accounts | Admins absents du groupe Protected Users (5) | +10 | *Corrigé* |
| Privileged Accounts | OUs sans protection contre la suppression accidentelle | Informatif | À corriger |
| Stale Objects | Protocoles NTLMv1 et LM autorisés | +15 | *Corrigé* |
| Stale Objects | Utilisateurs non-admin peuvent joindre 10 machines | +10 | *Corrigé* |
| Stale Objects | WSUS configuré en HTTP non chiffré | +5 | À corriger |
| Stale Objects | Sous-réseaux incomplets (3 IP de DC non déclarées) | +5 | À corriger |
| Stale Objects | Certificate Pinning WSUS désactivé | +2 | À corriger |
| Stale Objects | WSUS accepte les proxys utilisateur | +1 | À corriger |
| Trusts | AES non activé sur tous les trusts | +1 | À corriger |

---

## 3. Outils utilisés

- **PingCastle** – Audit de sécurité Active Directory
- **Microsoft LAPS** – Gestion des mots de passe administrateurs locaux
- **Windows Server Backup** – Sauvegarde du contrôleur de domaine
- **GPMC** – Déploiement des corrections via stratégies de groupe

---
