# Configuration du Reverse Proxy Apache

Ce document détaille les étapes de configuration effectuées. Le proxy reçoit tout le trafic (interne via DNS split-horizon ou externe via NAT pfSense), termine le chiffrement TLS et relaie les requêtes vers le serveur web vitrine (10.50.0.6) sans l’exposer directement.

### 1. Activation des modules Apache nécessaires

Commande exécutée :

a2enmod proxy proxy_http ssl rewrite headers

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/01_proxy_configuration.jpg)

Une erreur apparaît sur « proxy-http » (tiret au lieu d’underscore), mais la commande active correctement « proxy_http ».  

Redémarrage du service :

    systemctl restart apache2

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/02_proxy_configuration.jpg)

Rôles des modules :
- proxy + proxy_http : relais inverse  
- ssl : terminaison TLS  
- rewrite : redirection HTTP → HTTPS  
- headers : ajout d’en-têtes de sécurité (durcissement)

### 2. Création du certificat auto-signé

Commande exécutée :

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/ecotech.key \
    -out /etc/ssl/certs/ecotech.crt \
    -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/OU=IT/CN=www.ecotech-solutions.com"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/03_proxy_configuration.jpg)

Caractéristiques :
- Validité : 365 jours  
- Clé privée : RSA 2048 bits sans mot de passe (-nodes)  
- Emplacements : /etc/ssl/private/ et /etc/ssl/certs/  
- Common Name (CN) : www.ecotech-solutions.com (cohérent avec le DNS et les URL)

Retour de prompt (c'est jolie hein!)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/04_proxy_configuration.jpg)

### 3. Création et édition du fichier de configuration

Fichier créé/édité :

nano /etc/apache2/sites-available/reverse-proxy.conf

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/05_proxy_configuration.jpg)

Contenu saisi :

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/06_proxy_configuration.jpg)

Éléments clés de la configuration :
- Bloc port 80 : redirection 301 vers HTTPS (RewriteRule)  
- Bloc port 443 : activation SSL + limitation aux protocoles TLS 1.2 et 1.3 (SSLProtocol)  
- ProxyPass / http://10.50.0.6/ : relais vers le serveur vitrine  
- ProxyPreserveHost On : conservation de l’en-tête Host original  
- Logs séparés : proxy_error.log et proxy_access.log

### 4. Activation du site et validation de la syntaxe

Commandes exécutées dans l’ordre :

a2dissite reverse-proxy.conf  
systemctl restart apache2  
a2ensite reverse-proxy.conf  
apache2ctl configtest  
systemctl reload apache2

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/cf7bd56ea04fa6598ae2c1bb11a5351987df1f65/components/web_ex/proxy_externe/ressources/config/07_proxy_configuration.jpg)

Résultat du test : Syntax OK  
Le reload permet d’appliquer les modifications sans interruption de service.

### Synthèse de la configuration

- Redirection automatique de HTTP vers HTTPS  
- Terminaison TLS sur le proxy (certificat auto-signé)  
- Relais inverse vers le serveur web 10.50.0.6  
- Serveur vitrine non exposé directement  
- Logs dédiés pour faciliter le suivi

Les tests fonctionnels (curl, navigateur, vérification des logs) restent à réaliser pour confirmer le bon fonctionnement global. 
