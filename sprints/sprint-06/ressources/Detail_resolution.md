# Plan de Reprise d'Activité — Résolution des pannes post-incident électrique

---

## Table des matières

  - [1. ECO-BDX-DX01 \& ECO-BDX-DX02 — Cluster de pare-feu](#1-eco-bdx-dx01--eco-bdx-dx02--cluster-de-pare-feu)
  - [2. ECO-BDX-AX01 — Switch L3](#2-eco-bdx-ax01--switch-l3)
  - [3. ECO-BDX-EX17 — Contrôleur de domaine (Rôle FSMO Infrastructure Master)](#3-eco-bdx-ex17--contrôleur-de-domaine-rôle-fsmo-infrastructure-master)
  - [4. ECO-BDX-EX13 — Serveur de messagerie (iRedMail)](#4-eco-bdx-ex13--serveur-de-messagerie-iredmail)

---

## 1. ECO-BDX-DX01 & ECO-BDX-DX02 — Cluster de pare-feu

**Contexte :**

L'incident électrique a rendu le cluster de pare-feu entièrement inopérant. La configuration initiale reposait sur une architecture redondante avec un pare-feu principal (ECO-BDX-DX01) et un pare-feu de secours (ECO-BDX-DX02), dont la bascule automatique était assurée par le protocole CARP.

**Diagnostic :**

Deux pannes simultanées ont été constatées :
- La carte réseau `vmbr511` du pare-feu principal (ECO-BDX-DX01) était défectueuse.
- Le pare-feu de secours (ECO-BDX-DX02) était lui aussi hors service, annulant toute capacité de basculement automatique.

**Solution mise en œuvre :**

Face à l'impossibilité de rétablir le cluster dans des délais acceptables, une architecture simplifiée a été adoptée en urgence :
- Conservation d'un seul pare-feu opérationnel.
- Désactivation du protocole de redondance CARP.

Cette solution permet de rétablir le filtrage réseau et la connectivité, tout en renonçant temporairement à la haute disponibilité.

**Points d'amélioration :**

- **Redondance matérielle :** La double panne simultanée démontre que la redondance logicielle (CARP) ne suffit pas si les deux équipements partagent les mêmes vulnérabilités physiques (alimentation commune, même baie). Une alimentation électrique séparée pour chaque nœud du cluster est recommandée.

- **Plan de reprise dégradée :** L'absence d'une procédure documentée de passage en mode simplifié (single firewall) a complexifié l'intervention. Ce scénario doit être intégré dans le PRA avec des étapes claires.

- **Rétablissement de la redondance :** La désactivation de CARP est une mesure temporaire d'urgence. Le rétablissement d'une architecture hautement disponible doit être planifié dès que le matériel de remplacement sera disponible.

- **Résilience électrique :** La présence d'onduleurs (UPS) dédiés et correctement dimensionnés sur chaque nœud du cluster est indispensable pour absorber les micro-coupures ou déclencher un arrêt propre en cas de coupure prolongée.

---

## 2. ECO-BDX-AX01 — Switch L3

**Contexte :**

Suite à un incident électrique, le switch L3 ECO-BDX-AX01 a présenté des dysfonctionnements sur ses cartes réseau, compromettant l'ensemble de la connectivité réseau en aval.

**Diagnostic :**

L'analyse post-incident a mis en évidence la défaillance de deux cartes réseau :
- `eth1` : interface assurant la jonction avec le routeur ECO-BDX-DX03
- `eth4` : interface assurant la connectivité avec l'ensemble des VLANs du réseau local (LAN)

**Solution mise en œuvre :**

Les deux cartes réseau défectueuses ont été remplacées par du matériel fonctionnel. Après remplacement physique, la table de routage a été entièrement reconfigurée afin de rattacher chaque VLAN au réseau. La communication a été validée via des tests de connectivité (`ping`, `traceroute`/`tracert`) entre les segments concernés.

**Points d'amélioration :**

- **Matériel de rechange :** L'absence de spare matériel a allongé le délai de remise en service. Disposer de cartes réseau compatibles en stock permettrait de réduire significativement le temps d'intervention.
- **Sauvegarde de la configuration :** La table de routage a dû être reconfigurée manuellement. Un export régulier et versionné de la configuration du switch (via TFTP ou solution NMS) éviterait cette étape chronophage.
- **Résilience électrique :** La coupure d'alimentation est directement à l'origine de la panne matérielle. Il convient de s'assurer que cet équipement critique est protégé par un onduleur (UPS) dimensionné correctement.

---


## 3. ECO-BDX-EX17 — Contrôleur de domaine (Rôle FSMO Infrastructure Master)

**Contexte :**
Suite à la coupure d'électricité, le contrôleur de domaine ECO-BDX-EX17, qui détenait le rôle FSMO **Infrastructure Master**, a été perdu et supprimé de l'environnement Active Directory. Les autres contrôleurs de domaine continuaient de référencer ce serveur inexistant comme détenteur du rôle, sans générer d'erreur visible.

**Diagnostic :**

| Critère | Avant | Après |
|---|---|---|
| Détenteur du rôle | ECO-BDX-EX17 (supprimé) | ECO-BDX-EX02 |
| Etat du rôle | Orphelin / inaccessible | Actif et fonctionnel |
| Impact | Références inter-domaines non mises à jour | Fonctionnement normal rétabli |

**Solution mise en œuvre :**

Le rôle a été récupéré manuellement depuis le contrôleur de domaine opérationnel ECO-BDX-EX02, via la console **Active Directory Utilisateurs et Ordinateurs (ADUC)**.

**Procédure de récupération :**

1. Ouvrir **ADUC** sur ECO-BDX-EX02.
2. Faire un clic droit sur le domaine `ecotech.local` > **Opérations Master**.
3. Aller sur l'onglet **Infrastructure**.
4. Cliquer sur **Change** pour tenter le transfert.
5. Le système signale que l'ancien détenteur est injoignable (_"The current FSMO holder could not be contacted"_) et propose un **transfert forcé**.
6. Confirmer avec **Yes** — le rôle est attribué à ECO-BDX-EX02.

**Points d'amélioration :**

- **Détection grâce à la supervision :** C'est le serveur de supervision qui a remonté l'absence du DC, et non l'Active Directory lui-même. Le domaine a continué de fonctionner avec 4 rôles FSMO sur 5 sans générer d'erreur, ce qui confirme que sans supervision externe, cette panne serait restée silencieuse.
- **Défaillance silencieuse :** Ce comportement souligne l'importance d'audits réguliers des rôles FSMO (`netdom query fsmo`) et d'alertes proactives côté supervision.
- **Résilience électrique :** La perte directe d'un DC suite à une coupure soulève la question de la présence et de l'efficacité d'un onduleur (UPS) sur les serveurs critiques.

---

## 4. ECO-BDX-EX13 — Serveur de messagerie (iRedMail)

**Contexte :**

Le serveur de messagerie ECO-BDX-EX13, basé sur iRedMail 1.7.4, a été intégralement perdu suite à la coupure d'électricité. Ce serveur assurait l'envoi, la réception et le stockage des emails professionnels pour le domaine de l'organisation. Aucune restauration n'a été possible faute de sauvegarde exploitable.

**Diagnostic :**

| Critère | Avant (serveur perdu) | Après (nouveau déploiement) |
|---|---|---|
| Adresse IP | 10.50.0.7 | 10.20.20.14 |
| Domaine mail | ecotech-solutions.com | ecotech-solutions.lan |
| FQDN | mail.ecotech-solutions.com | mail.ecotech-solutions.lan |
| Solution | iRedMail 1.7.4 | iRedMail 1.7.4 |
| Etat | Détruit | Réinstallation en cours |

**Solution mise en œuvre :**

Recréation complète du service de messagerie sur un nouveau container LXC privilégié (Debian 12), avec adaptation de l'adressage réseau au nouvel environnement. La migration de VM vers container LXC réduit la consommation de ressources. La documentation d'installation est mise à jour pour refléter les nouveaux paramètres (IP, domaine, type d'hébergement).

**Points d'amélioration :**

- **Aucune sauvegarde exploitable :** La perte totale du serveur sans possibilité de restauration met en évidence l'absence d'un plan de backup structuré. Il est impératif de mettre en place des snapshots Proxmox réguliers, un export périodique des boîtes mail (format Maildir ou mbox), et une sauvegarde externalisée de la configuration iRedMail (domaines, comptes, alias, règles).

- **Détection par la supervision :** Comme pour les autres incidents, c'est le serveur de supervision qui a détecté l'indisponibilité du service mail, et non une alerte applicative interne.

- **Temps de remise en service :** La réinstallation complète d'iRedMail est une opération longue. Un export documenté et maintenu à jour des paramètres critiques permettrait de réduire significativement le délai de rétablissement.

- **Résilience de l'hébergement :** Le passage en container LXC est une optimisation des ressources, mais ne résout pas le manque de redondance. Une réplication du service mail (secondaire MX, ou réplication LXC) devrait être envisagée pour les besoins futurs.

---
