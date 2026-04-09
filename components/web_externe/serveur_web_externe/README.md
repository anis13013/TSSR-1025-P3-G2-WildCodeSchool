# Serveur Web Vitrine – Hébergement du site EcoTech Solutions


Ce document présente le rôle et le positionnement du serveur web vitrine dans l’infrastructure. Vous y trouverez une vue d’ensemble de son fonctionnement, ainsi que les liens vers les guides d’installation et de configuration. Le serveur web vitrine n’est pas exposé directement sur le WAN ou le LAN ; tout le trafic transite par le reverse proxy pour respecter les principes de défense en profondeur.

### Rôle principal

Le serveur web vitrine héberge le site internet officiel d’EcoTech Solutions, qui présente l’entreprise, ses services, ses actualités et un formulaire de contact. Il s’agit d’un contenu public, mais protégé :
- Il répond uniquement aux requêtes provenant du reverse proxy (10.50.0.5).  
- Il n’est pas accessible directement depuis Internet (WAN) ou le réseau interne (LAN).  
- Il utilise Apache2 pour servir les pages statiques.  

Cette approche permet de :
- Isoler le serveur de contenu des attaques directes.  
- Centraliser le chiffrement TLS sur le proxy.  
- Faciliter les mises à jour du site sans impacter l’exposition publique.

### Positionnement dans l’infrastructure

| Élément                   | Adresse IP     | Zone / VLAN     | Rôle dans le flux vitrine                              |
|---------------------------|----------------|-----------------|--------------------------------------------------------|
| Reverse Proxy             | 10.50.0.5      | DMZ   | Point d’entrée unique (WAN + LAN)                      |
| Serveur web vitrine       | 10.50.0.6      | DMZ   | Héberge les pages – accessible uniquement via proxy   |
| pfSense                   | WAN publique   | WAN             | NAT 80/443 → 10.50.0.5                                 |
| Clients internes          | 10.60.x.x      | Métiers         | Résolution DNS interne → 10.50.0.5                     |

Flux typique :
- Utilisateur externe → pfSense NAT → Reverse Proxy (10.50.0.5) → Serveur web (10.50.0.6)  
- Utilisateur interne → DNS AD (split-horizon) → Reverse Proxy (10.50.0.5) → Serveur web (10.50.0.6)  

Le serveur web écoute sur HTTP (port 80) en interne, car le chiffrement est géré par le proxy.

### Logiciels installés

- Serveur web : Apache2  
- Modules utilisés : ssl, rewrite, headers (activés pour la compatibilité avec le proxy)  
- Contenu du site : Pages statiques placées dans /var/www/ecotechsolutions

### Sécurité appliquée

- Pas d’exposition directe sur WAN ou LAN (règles pare-feu pfSense et machine locale)  
- Accès limité au proxy (10.50.0.5)  
- Masquage de la bannière serveur (ServerTokens Prod)  
- Pas de chiffrement sur ce serveur (terminé au proxy)

### Validation du fonctionnement

- Test interne : curl http://10.50.0.6 depuis le proxy → page vitrine renvoyée  
- Test complet : navigation via proxy[](https://www.ecotech-solutions.com) → site affiché correctement  
- Logs : vérification dans /var/log/apache2/access.log et error.log  

### Liens vers les guides détaillés

- [Guide d’installation](install.md) : Étapes pour installer Apache2 sur la machine  
- [Guide de configuration](configuration.md) : Détails de la configuration VirtualHost et durcissement  
