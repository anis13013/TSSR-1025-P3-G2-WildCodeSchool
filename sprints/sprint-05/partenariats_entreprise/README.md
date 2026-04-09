# Sprint 5 - Partenariat Inter-Entreprises

## Contexte et Objectifs

En tant qu'administrateur de l'entreprise **EcoTech** (ecotech.local), j'ai collaboré avec l'entreprise partenaire **BillU** (billu.lan, gérée par Franck) et Matthias (responsable pfSense) afin de mettre en place une gestion Active Directory commune sécurisée et de configurer l'accès distant pour les membres IT du partenaire.

L'objectif principal de ce sprint était d'établir une relation de confiance entre les deux domaines tout en garantissant un contrôle fin des accès et un haut niveau de sécurité.

## Architecture et Technologies

- Windows Server
- Active Directory Domain Services
- Kerberos
- DNS (Redirecteurs conditionnels)
- Relations de confiance Active Directory
- Méthode AGDLP

## Réalisations techniques

- Ouverture des flux firewall sur pfSense (collaboration avec billu.lan)
- Configuration des redirecteurs conditionnels DNS entre les deux domaines
- Création d'une approbation de forêt bidirectionnelle entre ecotech.local et billu.lan
- Sécurisation via l'authentification sélective
- Implémentation de la méthode AGDLP pour les droits d'accès RDP
- Configuration des groupes de sécurité et des autorisations "Allowed to Authenticate"
- Tests de validation de l'accès distant

## Documentation détaillée

Pour voir la configuration étape par étape avec captures d'écran, consultez la documentation détaillée dans le fichier configuration.md



