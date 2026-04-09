# Composant : DNS (Domain Name System)

## 1. Présentation du Service
Le service DNS est une brique fondamentale de l'infrastructure d'**EcoTech Solutions**. Il permet la résolution de noms de domaine au sein de l'annuaire `ecotech.local`, indispensable au bon fonctionnement d'Active Directory (AD DS) et à la localisation des services par les clients (Windows et Ubuntu).

## 2. Architecture et Rôles
Le service est déployé de manière redondante sur deux contrôleurs de domaine :

| Serveur | Rôle | Système d'Exploitation | Adresse IP |
| :--- | :--- | :--- | :--- |
| **ECO-BDX-EX01** | DC Principal / DNS Primaire | Windows Server 2022 Core | 10.20.20.5 |
| **ECO-BDX-EX02** | DC Secondaire / DNS Secondaire | Windows Server 2022 GUI | 10.20.20.6 |

## 3. Configuration Technique Clef

### A. Redirecteurs (Forwarders)
Pour permettre la résolution des noms externes (accès Internet pour les mises à jour et le proxy), le serveur DNS redirige les requêtes inconnues vers :
1. **Passerelle pfSense** : `10.40.0.1`
2. **DNS Public (Google)** : `8.8.8.8`

### B. Sécurisation et Transferts de Zone
Conformément au modèle de **Tiering** et aux exigences de sécurité :
- Le transfert de zone est strictement restreint.
- Seul le serveur secondaire (`10.20.20.6`) est autorisé à répliquer les informations de la zone `ecotech.local`.

### C. Adressage Client
Les serveurs sont configurés pour s'interroger eux-mêmes en priorité via l'adresse de bouclage (`127.0.0.1`) avant de solliciter le partenaire de réplication.

## 4. Documentation Détaillée
Pour plus de détails sur la mise en œuvre technique, consultez les fichiers suivants :

- **[Installation du service](installation.md)** : Étapes d'installation du rôle DNS via PowerShell (Core) et interface graphique (GUI).
- **[Configuration du service](configuration%20(1).md)** : Détails des commandes PowerShell pour les forwarders et la sécurisation des zones.

## 5. Matrice de Flux (Résumé)
| Source | Destination | Port | Protocole | Description |
| :--- | :--- | :--- | :--- | :--- |
| Clients LAN | Serveurs DNS | 53 | UDP/TCP | Requêtes DNS |
| DNS Primaire | DNS Secondaire | 53 | TCP | Transfert de zone |
| Serveurs DNS | pfSense (Gateway) | 53 | UDP | Redirection externe |
