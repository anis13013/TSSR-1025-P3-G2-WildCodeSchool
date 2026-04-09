# Projet FreePBX - Système de Téléphonie VoIP
----

**Ce dépôt contient toute la documentation nécessaire pour comprendre, reproduire et utiliser le serveur **FreePBX** que j’ai installé et configuré pour mon projet de téléphonie VoIP.**

Le serveur permet actuellement :
- La gestion de deux postes internes (Poste1 et Poste2)
- L’enregistrement de softphones 3CXPhone
- Un firewall sécurisé (Sangoma Smart Firewall + Responsive Firewall)
- Des appels internes fonctionnels

---

## Structure du dépôt

- **INSTALLATION.md** → Guide complet de l’installation depuis l’ISO jusqu’à la fin du wizard initial  
- **CONFIGURATION.md** → Guide détaillé de la configuration post-installation (firewall, extensions, softphones)  
- **ressources** → Toutes les captures d’écran utilisées dans les documentations  
- **README.md** → Ce fichier (vue d’ensemble et utilisation courante)

---

### Postes configurés (Extensions)

| Extension | Nom      | MACHINE   | Statut          | Softphone utilisé |
|-----------|----------|--------|-----------------|-------------------|
| **1000**  | Poste1   | ECO-BDX-GX01  | Connecté        | 3CXPhone          |
| **1001**  | Poste2   | ECO-BDX-CX01  | Connecté        | 3CXPhone          |
