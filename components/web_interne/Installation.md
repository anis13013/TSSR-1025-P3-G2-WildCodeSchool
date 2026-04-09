# Installation du Serveur Web Intranet

Ce document détaille les étapes de création du conteneur et l'installation du moteur web.

## Installation du Service Apache

- Le système d'exploitation de base est Debian 12.

### Mise à jour des dépôts

- Avant toute installation, le système est mis à jour :

``` Bash

apt update && apt upgrade -y
Installation du paquet
La commande suivante installe le serveur web et ses dépendances :

```

### Installation du serveur Web **APACHE2**

- L'installation d'Apache peut s'effectuer.

``` Bash

apt install apache2 -y
Vérification initiale
On s'assure que le service a démarré correctement :

Bash
systemctl status apache2
Résultat attendu : Le statut doit indiquer active (running).

```

- L'environnement est prêt à être configuré.
