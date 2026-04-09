

### Perspectives d'évolution et d'amélioration du SI

| Catégorie | Composant | Ce qui aurait pu être fait (Amélioration) |
| :--- | :--- | :--- |
| **1. Infrastructure & Sécurité** | **RÉSEAU** | Créer de la redondance sur le matériel pour assurer une haute disponibilité et la tolérance de pannes. |
| | **PARE-FEU** | Affiner les règles pour un filtrage granulaire apportant un niveau de sécurité supérieur. |
| | **SAUVEGARDE** | Mettre en place la solution Bareos et configurer des sauvegardes incrémentales régulières. |
| **2. Système & Annuaire** | **Active Directory** | Sécuriser les échanges en passant le domaine sous LDAPS (LDAP over SSL). |
| | **GPO** | Appliquer davantage de politiques d'installation et de restrictions pour automatiser l'intégration et le déploiement de nouveaux outils. |
| | **DOSSIERS PARTAGÉS** | Mapper les dossiers (utilisateur, service, département) via GPO pour l'obfuscation, évitant ainsi l'affichage des chemins réseau en clair par l'AD. |
| **3. Services & Support** | **SERVEUR WEB INTERNE** | Déployer un portail centralisant les services de l'entreprise (raccourcis GLPI, accès web aux dossiers partagés, etc.). |
| | **Messagerie** | Lier le serveur de messagerie directement à l'annuaire LDAP pour l'authentification unifiée. |
| | **GLPI** | Structurer la plateforme en créant l'ensemble des catégories de tickets et de matériels. |
| | **VoIP** | Créer un groupe d'appel dédié au support IT pour faciliter le contact avec les utilisateurs en cas d'incident. |
