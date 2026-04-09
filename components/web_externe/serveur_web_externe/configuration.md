# Configuration du serveur web Apache2 pour le site ecotech

## Objectif
Mettre en place un VirtualHost sécurisé pour le domaine www.ecotech-solutions.com  
- Accès restreint à une IP précise (exemple : proxy ou réseau interne 10.50.0.5)  
- Permissions strictes sur les fichiers et dossiers  
- Logs dédiés par site  
- Hardening de base Apache (masquage de la version, désactivation de méthodes dangereuses)

Environnement : Debian/Ubuntu sur conteneur LXC Proxmox.

## 1. Création du répertoire du site
Commande exécutée :

    mkdir -p /var/www/ecotech

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/01_web_configuration.jpg)

## 2. Permissions et propriétaire (sécurité critique)
Commande exécutée :

    chown -R www-data:www-data /var/www/ecotech

find /var/www/ecotech/ -type d -exec chmod 755 {} \;

find /var/www/ecotech/ -type f -exec chmod 644 {} \;

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/02_web_configuration.jpg)


## 3. Création du fichier VirtualHost

**Fichier : /etc/apache2/sites-available/ecotech.conf**

      nano /etc/apache2/sites-available/ecotech.conf

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/03_web_configuration.jpg)


Édité comme ceci:


    <VirtualHost *:80>
    ServerName www.ecotech-solutions.com
    ServerAlias ecotech-solutions.com
    ServerAdmin admin@ecotech-solutions.com

    DocumentRoot /var/www/ecotech

    <Directory /var/www/ecotech>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require ip 10.50.0.5
        # Pour être plus strict : 
        # <RequireAny>
        #     Require ip 10.50.0.5
        #     Require all denied
        # </RequireAny>
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/ecotech_error.log
    CustomLog ${APACHE_LOG_DIR}/ecotech_access.log combined
    </VirtualHost>

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/04_web_configuration.jpg)


## 4. Hardening global d'Apache

Fichier recommandé : /etc/apache2/conf-available/security.conf

Commande exécutée :

    nano /etc/apache2/conf-available/security.conf

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/07_web_configuration.jpg)

Édité comme ceci:

    ServerTokens Prod
    ServerSignature Off
    TraceEnable Off

*TRACE peut être utilisé dans certaines attaques : vol d’informations dans les headers (cookies, auth), attaque Cross-Site Tracing (XST), reconnaissance d’infrastructure*


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/08_web_configuration.jpg)


Activer si le fichier existe déjà :

Commande exécutée :
        
        a2enconf security

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/05_web_configuration.jpg)


## 5. Activation et vérification

Commande exécutée :

    apache2ctl configtest

    a2ensite ecotech.conf

    a2dissite 000-default.conf   # optionnel mais recommandé

    systemctl reload apache2

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/f0d4069030078ef0cf97a22770393b060a722571/components/web_ex/serveur_web_externe/ressources/config/06_web_configuration.jpg)


**Si reload échoue, utiliser restart**

     systemctl restart apache2

    systemctl status apache2

## 6. Tests de base à effectuer

Depuis l'IP autorisée (ex. 10.50.0.5) :

    curl -I http://10.50.0.6

Depuis une autre IP :

    curl -I http://10.50.0.6    #doit retourner 403 Forbidden

Vérifier l'en-tête Server :

Commande exécutée :

    curl -sI http://IP_DU_SERVEUR | grep -i server

doit afficher seulement : Server Apache   (pas de version)

## 7. Optionnel : 

- Surveiller les logs :
  tail -f /var/log/apache2/ecotech_error.log

**En cas d'erreur sur apache2ctl configtest, corriger la syntaxe indiquée avant de recharger.**
