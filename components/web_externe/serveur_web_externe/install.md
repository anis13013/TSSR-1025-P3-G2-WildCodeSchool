# Installation du serveur web Apache


Ce document décrit les étapes d’installation réalisées sur la machine. Vous trouverez ci-dessous les commandes exécutées.

### 1. Mise à jour de la liste des paquets

Commande exécutée :

    apt update

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d8ed4d9c1059e80b13cb8c54c055f2a8d9108f99/components/web_ex/serveur_web_externe/ressources/install/01_web_install.jpg)


### 2. Installation du paquet apache2

Commande exécutée :

    apt install apache2 -y

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d8ed4d9c1059e80b13cb8c54c055f2a8d9108f99/components/web_ex/serveur_web_externe/ressources/install/02_web_install.jpg)

Lors d’une première installation, des lignes de téléchargement et de configuration automatique apparaîtraient.

### 3. Vérification du statut du service Apache2

Commande exécutée :

    systemctl status apache2

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/d8ed4d9c1059e80b13cb8c54c055f2a8d9108f99/components/web_ex/serveur_web_externe/ressources/install/03_web_install.jpg)

- Statut : active (running) le service fonctionne normalement  
- Enabled : oui démarrage automatique au boot  

### Synthèse des commandes utilisées

- Mise à jour des paquets : apt update  
- Installation d’Apache2 : apt install apache2 -y  
- Vérification du service : systemctl status apache2  

### État actuel

Apache2 est installé et en cours d’exécution.  
Le serveur écoute par défaut sur le port 80 (testable avec curl http://10.50.0.5 depuis un poste du réseau).

### Prochaines étapes (déjà réalisées)

- Activation des modules proxy, proxy_http, ssl, rewrite, headers  
- Création du certificat auto-signé  
- Configuration du fichier reverse-proxy.conf  
- Activation du site et test de syntaxe (apache2ctl configtest)  
- Reload du service (systemctl reload apache2)

Ces étapes sont détaillées dans le fichier **configuration.md**.

