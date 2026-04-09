# Installation simple de Zabbix 7.0 sur Debian 12 (Proxmox LXC)

---

## Objectif : 
Installer Zabbix 7.0 (logiciel de supervision open-source) sur une machine Debian 12.
Ce guide est destiné aux débutants : chaque commande est expliquée simplement.

Version ciblée : Zabbix 7.0 LTS



Étapes d’installation
### 1. Mise à jour du système
Rafraîchir la liste des paquets disponibles (toujours la première étape) :

        apt update

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_serveur_zabbix/04_.jpg)


### 2. Installation des outils de base utiles
text

        apt install wget curl nano gnupg2 -y

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_serveur_zabbix/01_.jpg)

Explication des outils installés :


*gnupg2 : Vérifier les signatures des paquets (sécurité)*


### 3. Ajout du dépôt officiel Zabbix 7.0

Téléchargez le paquet qui ajoute le dépôt Zabbix :

    wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_serveur_zabbix/02_.jpg)

*Vérifiez toujours sur la page officielle :
https://www.zabbix.com/download → Debian 12 → onglet « Zabbix 7.0 » → copiez le lien wget exact.*

Installez ensuite ce paquet :

    dpkg -i zabbix-release_7.0-1+debian12_all.deb

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_serveur_zabbix/03_.jpg)

*Cette commande crée le fichier /etc/apt/sources.list.d/zabbix.list → votre système sait maintenant où trouver les paquets Zabbix récents.*


### 4. Installation des paquets Zabbix principaux

Commande principale qui installe presque tout ce dont on a besoin :
text

    apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server -y

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_serveur_zabbix/05_.jpg)


Rôle de chaque paquet (explications simples) :

*zabbix-server-mysql : Le moteur principal (collecte, stocke et calcule les données)
zabbix-frontend-php : L’interface web (ce que vous voyez dans le navigateur)
zabbix-apache-conf : Configuration prête à l’emploi pour Apache + Zabbix
zabbix-sql-scripts : Fichiers SQL pour créer la structure de la base de données
zabbix-agent : Petit programme à installer sur les machines que vous voulez surveiller
mariadb-server : Serveur de base de données (compatible MySQL)*

----

# Installation simple de Zabbix 7.0 sur Debian 12 (Proxmox LXC) – Suite

**(suite de la partie précédente – après installations des paquets Zabbix)**

### 5. Sécurisation et configuration initiale de MariaDB

MariaDB est installé, mais il faut le sécuriser et le préparer.

D'abord, on se connecte en root MariaDB (souvent sans mot de passe au début) :

    mariadb -uroot

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/01_.jpg)

*Ensuite, dans le prompt MariaDB, on crée :

la base de données zabbix
l'utilisateur zabbix@localhost
on lui donne tous les droits sur la base zabbix

    CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'Azerty1*'; # Définissez votre mot de passe à la place d'Azerty1*
    GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
    SET GLOBAL log_bin_trust_function_creators = 1;

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/02_.jpg)

### 6. Import du schéma initial de Zabbix
C'est l'étape qui remplit la base avec les tables et données de base de Zabbix :

        zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mariadb --default-character-set=utf8mb4 -uzabbix -p zabbix

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/03_.jpg)

*Entrez le mot de passe lorsque demandé.
Cette commande peut prendre 10–60 secondes selon la machine.*

### 7. Configuration du serveur Zabbix
Modifiez le fichier de configuration :

        nano /etc/zabbix/zabbix_server.conf

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/05_.jpg)

Assurez-vous que ces lignes sont présentes et correctement remplies (décommentez si nécessaire) :

    DBHost=localhost
    DBName=zabbix
    DBUser=zabbix
    DBPassword=VotreMotDePasseTresFort

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/06_.jpg)

*Enregistrez (Ctrl+O → Enter → Ctrl+X).*



### 8. Redémarrage et activation des services
Redémarrez les services pour appliquer les modifications :

        systemctl restart zabbix-server zabbix-agent apache2

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/10_.jpg)

Activez-les au démarrage automatique :

    systemctl enable zabbix-server zabbix-agent apache2


### 9. Configuration des locales (dpkg-reconfigure locales)


        dpkg-reconfigure locales

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/3d55b00eaf454fa65c8170a74d6f51fe4e995baa/components/zabbix/ressources/installation_mariadb/07_.jpg)

*Écran affiché :
Si vous voulez que l'interface Zabbix affiche correctement le français (ou d'autres langues) dans le wizard d'installation et dans les menus. Sans locales UTF-8 installées sur le serveur, les langues supplémentaires restent grisées ou ne fonctionnent pas bien.
Vous cochez une ou plusieurs locales UTF-8 (exemples vus : fr_FR.UTF-8, en_US.UTF-8, etc.). Vous choisissez une locale par défaut (souvent fr_FR.UTF-8 ou en_US.UTF-8)*

**Ceci est important car Zabbix utilise les locales du système pour afficher correctement les traductions (français, dates, etc.) dans l'interface web.**





