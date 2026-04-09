# Installation du Reverse Proxy Apache

Ce document décrit les étapes d’installation réalisées sur la machine pour préparer le reverse proxy.

## Prérequis

## Étapes réalisées

### 1. Mise à jour des paquets

Commande exécutée :

    apt update

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/89f22bba22eac71f395106e8f6cd597ef9e6b9e1/components/web_ex/proxy_externe/ressources/install/01_proxy_install.jpg)


### 2. Installation du paquet apache2

Commande exécutée :

    apt install apache2 -y

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/89f22bba22eac71f395106e8f6cd597ef9e6b9e1/components/web_ex/proxy_externe/ressources/install/02_proxy_install.jpg)

Le message indique qu’il s’agit de la version la plus récente disponible.

### 3. Vérification du service Apache2

Commande exécutée :

    systemctl status apache2

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/89f22bba22eac71f395106e8f6cd597ef9e6b9e1/components/web_ex/proxy_externe/ressources/install/03_proxy_install.jpg)



## Vérifications post-installation

- La page par défaut Apache devrait être visible (It works!) si aucun VirtualHost n’est encore configuré

## Prochaines étapes (déjà planifiées)

- Activation des modules proxy, proxy_http, ssl, rewrite, headers  
- Création du certificat auto-signé OpenSSL  
- Configuration des VirtualHosts (reverse-proxy.conf)  
- Durcissement (ServerTokens Prod, ServerSignature Off)  
- Tests de redirection HTTP → HTTPS et ProxyPass vers 10.50.0.6

Ces étapes sont détaillées dans le fichier **configuration.md** du composant.
