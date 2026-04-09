# Infrastructure de Messagerie – iRedMail Open Source
## Contexte du Projet

Dans le cadre de la refonte de l'infrastructure d'EcoTechSolutions et de la volonté de souveraineté numérique, la mise en place d’un serveur de messagerie électronique autonome est devenue stratégique.  
L’objectif est de sortir de la dépendance aux solutions SaaS externes (Google Workspace, Microsoft 365, ProtonMail, etc.) tout en garantissant confidentialité, contrôle total des données et résilience.

**iRedMail** agit comme la **plateforme de messagerie** de l’organisation : il gère l’envoi, la réception, le stockage et l’accès sécurisé aux emails professionnels, avec une interface d’administration centralisée et un webmail.

## Objectifs Stratégiques

L’implémentation de ce service répond à cinq besoins :

1. **Confidentialité**  
   Toutes les données email restent sur nos infrastructures, sans transit par des tiers.

2. **Disponibilité et Fiabilité**  
   Garantir un taux de disponibilité élevé (>99,9 %) avec détection proactive des problèmes (disque saturé, file d’attente SMTP bloquée, etc.).

3. **Centralisation de la Gestion**  
   Une interface unique (iRedAdmin) pour administrer domaines, boîtes, alias, quotas et forwarding.

4. **Compatibilité et Universalité**  
   Support complet des clients mail standards (Outlook, Thunderbird, iOS, Android) via IMAP/SMTP sécurisés + webmail Roundcube intégré.

## Architecture Technique

### Les ressources

- **Moteur de Messagerie** : iRedMail 1.7.4  
- **Système d’Exploitation** : Debian 12 
- **Serveur SMTP** : Postfix  
- **Serveur IMAP/POP3** : Dovecot  
- **Serveur Web & Webmail** : Nginx + Roundcube  
- **Interface d’Administration** : iRedAdmin  
- **Anti-spam / Antivirus** : SpamAssassin + ClamAV + Amavis  
- **Monitoring** : Netdata  
- **Protection** : Fail2Ban 
- **Base de Données** : MariaDB  

### Périmètre Fonctionnel

Le serveur gère :

- Boîtes mail individuelles, alias, listes de diffusion  
- Webmail (Roundcube)    
- Filtrage anti-spam et antivirus en temps réel  
- Quotas par utilisateur / domaine  
- Monitoring système et applicatif intégré
