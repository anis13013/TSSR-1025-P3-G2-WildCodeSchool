# Configuration post-installation de l'interface web Zabbix 7.0


---

- **Configuration web niveau serveur zabbix**

- **Configuration d'une antenne zabbix + certificat TLS**

- **Configuration Vyos 'agent config'**

- **Dashboard**

---

## Bienvenue et choix de la langue par défaut

Une fois les services redémarrés, ouvrez votre navigateur et accédez à l'adresse :
http://IP-de-votre-serveur/zabbix

- Vous arrivez sur l'écran "Welcome to Zabbix 7.0".
- Sélectionnez la langue par défaut dans la liste déroulante : **English (en_US)**.
- Cliquez sur **Next step** (Prochaine étape).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/01_zabbixweb.jpg)


### Étape 2 : Vérification des prérequis et connexion à la base de données

- L'assistant vérifie PHP, extensions, etc. → passez si tout est OK.
- Configurez la connexion DB (comme sur la capture) :
  - Type de base : **MySQL**
  - Hôte : **localhost**
  - Port : **0** (défaut)
  - Nom de la base : **zabbix**
  - Utilisateur : **zabbix**
  - Mot de passe : **Azerty1*** (ou celui que vous avez défini)
  - Stockage des identifiants : **Texte brut** (simple pour débuter)
- Cliquez sur **Prochaine étape**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/02_zabbixweb.jpg)


### Étape 3 : Paramètres du serveur (Nom, fuseau horaire, thème)

- Nom du serveur Zabbix : **ECO-BDX-EX10** (ou le nom que vous souhaitez)
- Fuseau horaire par défaut : **Système (UTC+00:00) UTC** (choisissez Europe/Paris si disponible)
- Thème par défaut : **Sombre** 
- Cliquez sur **Prochaine étape** puis **Installer**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/03_zabbixweb.jpg)


### Étape 4 : Succès de l'installation

- Message de félicitations : "Félicitations ! Vous avez installé l'interface Zabbix avec succès."
- Fichier de configuration `conf/zabbix.conf.php` créé.
- Cliquez sur **Terminé** → vous êtes redirigé vers la page de login.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/04_zabbixweb.jpg)


### Étape 5 : Connexion initiale et changement du mot de passe Admin

Identifiants par défaut :
- Nom d'utilisateur : **Admin**
- Mot de passe : **zabbix** (ou vide si pas changé)

**Attention** :
- Si vous tapez un mauvais mot de passe plusieurs fois → blocage temporaire ("Le compte est temporairement bloqué").
- Utilisez le bon mot de passe pour vous connecter.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/05_zabbixweb.jpg)

Une fois connecté :
- Allez dans **Administration → Utilisateurs** (ou directement sur le profil Admin).
- Cliquez sur **Admin** → onglet **Utilisateur**.
- Dans la section **Mot de passe** :
  - Entrez l'ancien mot de passe (si demandé).
  - Définissez un **nouveau mot de passe fort** (changez-le immédiatement pour la sécurité !).
  - Confirmez-le deux fois.
- Sélectionnez éventuellement :
  - Langue : **Valeur système par défaut** (ou French si disponible après locales)
  - Fuseau horaire : **Valeur système par défaut (UTC+00:00) UTC**
  - Thème : **Valeur système par défaut** (ou Sombre)
- Cliquez sur **Actualiser** (Update).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/06_zabbixweb.jpg)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/07_zabbixweb.jpg)

### Étape 6 : Création d'un hôte exemple (pour monitorer un serveur)

Allez dans **Configuration → Hôtes** → cliquez sur **Créer un hôte** (Create host).

Exemple basé sur les captures (hôte secondaire AD) :

- **Nom de l'hôte** : ECO-BDX-EX02
- **Nom visible** : ECO-BDX-EX02 (Serveur AD secondaire)
- **Modèles** : Sélectionnez **Windows by Zabbix agent** (ou un template adapté Windows)
- **Groupes d'hôtes** : Ajoutez **Windows Servers** (ou créez-le si absent)
- **Interfaces** :
  - Type : **Agent**
  - Adresse IP : **10.20.20.6**
  - Port : **10050** (défaut pour agent Zabbix)
- **Chiffrement** (onglet Chiffrement) :
  - Connexion à l'hôte : **PSK**
  - Identité PSK : **PSK.ECO-BDX-EX02** (exemple)
  - PSK : **ff1e74b0f166a94829d22deac0d2af2e7d8b d59e c9233bce9045** (générez un vrai PSK fort !)
- Cliquez sur **Ajouter**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/11_zabbixweb.jpg)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/configuration_web_zabbix_bienvenue_et_choix_de_la_langue_par_defaut/12_zabbixweb.jpg)

*L'hôte apparaît maintenant dans la liste des hôtes surveillés. Vous pouvez ajouter des items, triggers, etc., via les templates appliqués.

**Astuces rapides :**
- Changez toujours le mot de passe Admin dès la première connexion.
- Si le français n'apparaît pas dans les options de langue → revenez en console serveur et relancez dpkg-reconfigure locales pour ajouter fr_FR.UTF-8 UTF-8, puis redémarrez Apache.
- Pour plus d'hôtes : installez l'agent Zabbix sur les machines cibles et configurez PSK ou certificat pour la sécurité.


----

## Configuration d'un proxy Zabbix avec chiffrement TLS par certificats

Pour distribuer la charge de supervision (ex. : surveiller des sites distants sans ouvrir trop de ports), vous pouvez ajouter un **proxy Zabbix** chiffré en TLS certificats (plus sécurisé que PSK pour certains scénarios).

### 1. Préparation des certificats (sur le serveur Zabbix principal)

Créez un dossier sécurisé pour les fichiers TLS :


    mkdir -p /etc/zabbix/zabbix_ssl
    cd /etc/zabbix/zabbix_ssl

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/03_.jpg)


Changez le propriétaire pour que seul l'utilisateur zabbix puisse lire :

    chown -R zabbix:zabbix /etc/zabbix/zabbix_ssl
    chmod 600 /etc/zabbix/zabbix_ssl/*.key   # Pour les clés privées

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/05_.jpg)

Générez les certificats

Créez la clé privée du proxy

    openssl genrsa -out ex11.key 2048

Créez la demande de signature (CSR) avec les infos de votre organisation 

    openssl req -new -key ex11.key -out ex11.csr -subj "/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/CN=ECO-BDX-EX11"

Signez la CSR avec votre CA root (rootCA.crt et rootCA.key déjà existants) 

    openssl x509 -req -in ex11.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out ex11.crt -days 365 -sha256

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/04_.jpg)

Copiez les fichiers nécessaires vers le proxy distant (ex. via scp) :

    scp rootCA.crt ex11.crt ex11.key root@10.20.20.13:/etc/zabbix/zabbix_ssl/

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/08_.jpg)

2. Configuration sur le serveur Zabbix principal

Éditez /etc/zabbix/zabbix_server.conf :

    nano /etc/zabbix/zabbix_server.conf

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/10_.jpg)

Ajoutez ou modifiez ces lignes :

    TLSCAFile=/etc/zabbix/zabbix_ssl/rootCA.crt
    TLSCertFile=/etc/zabbix/zabbix_ssl/ex10.crt     # Cert du serveur
    TLSKeyFile=/etc/zabbix/zabbix_ssl/ex10.key      # Clé du serveur

Redémarrez le serveur :
          
    systemctl restart zabbix-server

3. Installation et configuration du proxy Zabbix (sur la machine distante)

Installez le paquet proxy (comme sur votre capture) :

    wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
    dpkg -i zabbix-release_7.0-1+debian12_all.deb
    apt update && apt install zabbix-proxy-sqlite3 -y

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/02_.jpg)

Créez le dossier SSL et ajustez les droits (identique au serveur) :

    mkdir -p /etc/zabbix/zabbix_ssl
    chown -R zabbix:zabbix /etc/zabbix/zabbix_ssl

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/07_.jpg)

Éditez /etc/zabbix/zabbix_proxy.conf :

    nano /etc/zabbix/zabbix_proxy.conf

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/10_.jpg)

**Paramètres clés configurés :**

    **Hostname=ECO-BDX-EX11**
    **Server=10.20.20.12          # IP du serveur Zabbix principal**
    **DBName=/var/lib/zabbix/zabbix_proxy.db**
    **ProxyMode=0                 # 0 = active (le proxy se connecte au serveur)**

Chiffrement TLS certificats :

    TLSConnect=cert
    TLSAccept=cert
    TLSCAFile=/etc/zabbix/zabbix_ssl/rootCA.crt
    TLSCertFile=/etc/zabbix/zabbix_ssl/ex11.crt
    TLSKeyFile=/etc/zabbix/zabbix_ssl/ex11.key
    TLSServerCertIssuer=/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/CN=EcoTech-CA
    TLSServerCertSubject=/C=FR/ST=Gironde/L=Bordeaux/O=EcoTech/CN=ECO-BDX-EX10*

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/11_.jpg)


Redémarrez et activez le proxy :

    systemctl restart zabbix-proxy
    systemctl enable zabbix-proxy

4. Ajout du proxy dans l'interface web Zabbix

Connectez-vous à l'interface web avec Admin.
Allez dans Administration → Proxies :

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/fbc7ae1e6de0d1b891695be0f2fb3a38aba640e3/components/zabbix/ressources/proxy_zabbix_configuration_tls/01_.jpg)


Cliquez sur Créer un proxy en haut à droite
Nom du proxy : ECO-BDX-EX11 (doit correspondre exactement au Hostname dans zabbix_proxy.conf)
Mode : Active (car ProxyMode=0)
Chiffrement : Certificat (ou PSK si vous changez)
PSK identity et PSK : laissez vide (puisque cert)
Sauvegardez.

Le proxy apparaît dans la liste. Attendez 1–2 minutes : la colonne État passe à "Actif", Version s'affiche, et Dernière observation se met à jour.
Vous pouvez maintenant assigner des hôtes à ce proxy (dans Configuration → Hôtes → onglet Proxy).
Sécurité importante :

Les clés privées (.key) sont très sensibles -> chmod 600 et propriétaire zabbix:zabbix.
Utilisez une vraie CA ou Let's Encrypt en production.


## Configuration de l'agent Zabbix sur VyOS (sans chiffrement)

Cette section explique comment installer et configurer l'agent Zabbix sur un routeur VyOS 
(version récente comme 1.4 ou 1.5), sans chiffrement TLS/PSK (mode passif ou actif simple).
L'objectif est de surveiller le routeur VyOS (interfaces, CPU, mémoire, services, etc.) 
depuis votre serveur Zabbix principal.

Étape 1 : Activer et configurer l'agent Zabbix via CLI VyOS

Connectez-vous en mode configuration :

    configure

Configurez l'agent Zabbix (mode actif, connexion vers le serveur) :

    set service monitoring zabbix-agent server '10.20.20.12'
    set service monitoring zabbix-agent server-active '10.20.20.12'
    set service monitoring zabbix-agent host-name 'ECO-BDX-DX03'


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/68a490ba6efdd8abb05ceea248c2b16f300bdd03/components/zabbix/ressources/configuration_vyos_configuration_agent_zabbix_sur_vyos/01_1.jpg)

*server : IP du serveur Zabbix (pour mode passif)
server-active : IP du serveur Zabbix (pour mode actif – recommandé pour VyOS derrière NAT/firewall)
host-name : Nom exact de l'hôte dans Zabbix (doit correspondre à ce que vous avez créé dans l'interface web)*

Validez et sauvegardez :

    commit
    save

Vérifier les configurations :
    
    show service monitoring zabbix-agent

Vérifiez les processus Zabbix :

    ps aux | grep zabbix

*Vous devriez voir quelque chose comme :* zabbix   292940  0.5  2.2 1249876 226640 ?  Ssl  11:43   
0:00 /usr/sbin/zabbix_agent2 --config /run/zabbix/zabbix_agent2.conf --foreground


Vérifiez les logs pour confirmer que l'agent communique bien :

    tail -f /var/log/zabbix/zabbix_agent2.log | grep zabbix

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/68a490ba6efdd8abb05ceea248c2b16f300bdd03/components/zabbix/ressources/configuration_vyos_configuration_agent_zabbix_sur_vyos/02_1.jpg)


*Logs typiques :*

*Chargement des plugins (VFS, Web, etc.)*
*Version du protocole : 6.0.13 ou supérieure*
*Hostname : ECO-BDX-DX03*


## Création d'un tableau de bord (Dashboard) dans Zabbix 7.0

Une fois vos hôtes surveillés (serveur principal, proxy, VyOS, etc.), l'étape suivante consiste à visualiser les données de façon claire et personnalisée via un **tableau de bord**.

### Étape 1 : Accéder à la section Tableaux de bord

Connectez-vous à l'interface web Zabbix :

- Allez dans **Surveillance → Tableaux de bord** (ou directement via le menu latéral gauche : **Tableaux de bord**)

- Barre de recherche et filtres (Nom, Afficher, Tous / Créé par moi)
- Bouton bleu **Créer un tableau de bord** en haut à droite
- Liste vide ou avec quelques dashboards par défaut/partagés ("À moi" ou "Partagé")

### Étape 2 : Créer un nouveau tableau de bord

Cliquez sur le bouton **Créer un tableau de bord** (Créer un tableau de bord).

Un éditeur s'ouvre avec une grille vide. Vous allez pouvoir ajouter des widgets (graphiques, problèmes, maps, etc.).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/067f2c866d5033037c0c44ce0b6a456cc5c356ad/components/zabbix/ressources/proxy_zabbix_configuration_tls/01_.jpg)

**Configuration de base d'un dashboard simple (exemple pour surveiller votre infrastructure)** :

1. **Nom du tableau de bord**  
   En haut à gauche : cliquez sur "Nouveau tableau de bord" et renommez-le, par exemple :  
   **Infrastructure ECO-BDX – Vue Globale**

2. **Ajouter des widgets**  
   Cliquez sur **Ajouter un widget** (bouton bleu en haut à droite ou directement sur la grille vide).

   Exemples de widgets utiles à ajouter :

   - **Graphique classique** ou **Graphique** :  
     - Sélectionnez un hôte (ex. ECO-BDX-EX10 ou ECO-BDX-DX03)  
     - Choisissez un item (ex. CPU load, Interface traffic eth0, Memory used)  
     - Type : Ligne, Barres, etc.

   - **Problèmes** :  
     Affiche la liste des triggers actifs (problèmes en cours) avec priorité (Info, Warning, Average, High, Disaster)


4. **Options globales du dashboard**  
   - Cliquez sur l'icône roue crantée (Paramètres) en haut à droite  
   - Définissez :  
     - Rafraîchissement automatique : 30s ou 1min  
     - Fuseau horaire : Europe/Paris  

5. **Enregistrer**  
   Cliquez sur **Enregistrer** (ou **Enregistrer et fermer**) en haut à droite.

----


**Note importante sur le déploiement des agents avec TLS**  

Dans notre infrastructure, les agents Zabbix ont été déployés de manière automatisée via un script d’installation centralisé. C’est la raison pour laquelle vous ne trouverez pas de captures d’écran détaillées de chaque étape manuelle ici.  
Ce tableau décrit précisément comment configurer manuellement un agent Zabbix en mode TLS avec certificats sur une machine Linux (serveur ou agent). Vous pouvez vous en servir pour comprendre le processus, le reproduire sur une nouvelle machine, ou dépanner un agent existant.  

Les commandes et chemins indiqués correspondent aux bonnes pratiques actuelles pour Zabbix 7.0 sur Debian 12.





| Étape | Explication simple                                                       | Commande / Emplacement                                                                                                     | Valeur par défaut / recommandée                               | Valeur à personnaliser (exemples)                                                                                                                                                          |
| ----- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1     | Créer un dossier sécurisé pour les certificats sur le serveur Zabbix     | mkdir -p /etc/zabbix/zabbix_ssl                                                                                            | /etc/zabbix/zabbix_ssl                                        | — (gardez ce chemin)                                                                                                                                                                       |
| 2     | Donner les droits corrects (seul l’utilisateur zabbix doit pouvoir lire) | chown -R zabbix:zabbix /etc/zabbix/zabbix_ssl<br>chmod 600 /etc/zabbix/zabbix_ssl/*.key                                    | Propriétaire = zabbix:zabbix<br>Clés = 600                    | —                                                                                                                                                                                          |
| 3a    | Générer la clé privée du serveur                                         | openssl genrsa -out server.key 2048                                                                                        | 2048 bits                                                     | —                                                                                                                                                                                          |
| 3b    | Créer la demande de signature (CSR)                                      | openssl req -new -key server.key -out server.csr -subj /C=FR/ST=Region/L=Ville/O=Entreprise/CN=votre-serveur-fqdn          | —                                                             | CN = zabbix.monentreprise.fr ou IP si pas de DNS                                                                                                                                           |
| 3c    | Signer le certificat avec votre CA                                       | openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt                        | Validité 365 jours                                            | —                                                                                                                                                                                          |
| 3d    | (Optionnel) Créer une CA root self-signed si vous n’en avez pas          | openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 1825 -nodes -subj /CN=MonEntreprise-CA                 | Validité 5 ans                                                | —                                                                                                                                                                                          |
| 4     | Placer les fichiers sur le serveur Zabbix                                | —                                                                                                                          | /etc/zabbix/zabbix_ssl/<br>ca.crt<br>server.crt<br>server.key | —                                                                                                                                                                                          |
| 5     | Modifier la configuration du serveur Zabbix                              | Éditez /etc/zabbix/zabbix_server.conf                                                                                      | TLSConnect=unencrypted par défaut                             | Ajouter :<br>TLSConnect=cert<br>TLSAccept=cert<br>TLSCAFile=/etc/zabbix/zabbix_ssl/ca.crt<br>TLSCertFile=/etc/zabbix/zabbix_ssl/server.crt<br>TLSKeyFile=/etc/zabbix/zabbix_ssl/server.key |
| 6     | Redémarrer le serveur Zabbix                                             | systemctl restart zabbix-server                                                                                            | —                                                             | —                                                                                                                                                                                          |
| 7     | Sur chaque machine avec l’agent                                          | mkdir -p /etc/zabbix/zabbix_ssl<br>chown -R zabbix:zabbix /etc/zabbix/zabbix_ssl<br>chmod 600 /etc/zabbix/zabbix_ssl/*.key | —                                                             | —                                                                                                                                                                                          |
| 8     | Copier les fichiers sur l’agent                                          | scp ca.crt agent.crt agent.key root@ip-agent:/etc/zabbix/zabbix_ssl/                                                       | —                                                             | agent.crt et agent.key : uniques par machine (ou même certificat si vous acceptez)                                                                                                         |
| 9     | Modifier la configuration de l’agent                                     | Éditez /etc/zabbix/zabbix_agent2.conf                                                                                      | TLSConnect=unencrypted par défaut                             | Ajouter :<br>TLSConnect=cert<br>TLSAccept=cert<br>TLSCAFile=/etc/zabbix/zabbix_ssl/ca.crt<br>TLSCertFile=/etc/zabbix/zabbix_ssl/agent.crt<br>TLSKeyFile=/etc/zabbix/zabbix_ssl/agent.key   |
| 10    | Redémarrer l’agent                                                       | systemctl restart zabbix-agent ou systemctl restart zabbix-agent2                                                          | —                                                             | —                                                                                                                                                                                          |
| 11    | Dans l’interface web Zabbix                                              | Hôte → onglet Chiffrement                                                                                                  | Pas de chiffrement                                            | Choisir Certificat<br>Ne pas remplir de PSK                                                                                                                                                |
| 12    | Vérifier que ça fonctionne                                               | Logs serveur : tail -f /var/log/zabbix/zabbix_server.log<br>Logs agent : tail -f /var/log/zabbix/zabbix_agent2.log         | —                                                             | Cherchez connection accepted ou using certificate                                                                                                                                          |

























