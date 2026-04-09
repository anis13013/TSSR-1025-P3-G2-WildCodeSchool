# Configuration du DNS Split-Horizon pour le site vitrine ecotech-solutions.com

Ce guide explique pas à pas comment créer et configurer la zone DNS interne **ecotech-solutions.com** sur le serveur DNS Windows (Active Directory) pour forcer les clients internes à passer par le Reverse Proxy (10.50.0.5).

**Prérequis**  
- Serveur Windows AD fonctionnel (ex : ECO-BDX-EX01 ou ECO-BDX-EX02)  
- Rôle DNS installé et actif  
- Accès administrateur au serveur (via RDP ou console Proxmox)  
- IP du Reverse Proxy connue : 10.50.0.5

## Étape 1 – Ouvrir le gestionnaire DNS

Ouvrez l’outil **DNS Manager** (dnsmgmt.msc) sur le serveur DNS.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/01_dns_configuration.jpg)

On voit ici l’arborescence DNS avec les zones existantes (.ecotech.local).  
On va créer une nouvelle zone Forward Lookup dans le dossier Forward Lookup Zones.

## Étape 2 – Créer une nouvelle zone (clic droit)

1. Cliquez droit sur **Forward Lookup Zones**  
2. Choisissez **New Zone…**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/02_dns_configuration.jpg)

C’est ici que l’on lance l’assistant de création de zone.

## Étape 3 – Choisir le type de zone : Primary

1. Sélectionnez **Primary zone**  
2. Cochez **Store the zone in Active Directory** (recommandé quand on est sur AD)  
3. Cliquez sur **Next**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/03_dns_configuration.jpg)

Primary zone = on peut modifier directement les enregistrements sur ce serveur.  
Stockage AD = la zone sera répliquée automatiquement sur les autres DC du domaine.

## Étape 4 – Choisir le scope de réplication

Choisissez **To all DNS servers running on domain controllers in this domain** (ecotech.local)

Cliquez sur **Next**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/04_dns_configuration.jpg)

C’est la meilleure option pour un petit domaine : réplication sur tous les DC du domaine ecotech.local.

## Étape 5 – Saisir le nom de la zone

Dans le champ **Zone name**, tapez exactement : ecotech-solutions.com

Cliquez sur **Next**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/05_dns_configuration.jpg)

Attention : utilisez un tiret (pas d’espace ni de point mal placé).  
C’est ce nom qui apparaîtra dans les enregistrements.

## Étape 6 – Dynamic Updates : Désactiver (sécurité)

Sélectionnez **Do not allow dynamic updates**

Cliquez sur **Next**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/06_dns_configuration.jpg)

On désactive les mises à jour dynamiques pour éviter qu’un client malveillant modifie la zone.  
Dans ce cas, tous les enregistrements seront créés manuellement.

## Étape 7 – Fin de l’assistant

Vérifiez le résumé :

- Name : ecotech-solutions.com  
- Type : Active Directory-Integrated Primary  
- Dynamic updates : Do not allow

Cliquez sur **Finish**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/07_dns_configuration.jpg)

La zone est maintenant créée et apparaît dans Forward Lookup Zones.

## Étape 8 – Ajouter les enregistrements A

1. Cliquez droit sur la nouvelle zone **ecotech-solutions.com**  
2. Choisissez **New Host (A or AAAA)…**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/08_dns_configuration.jpg)

On va créer deux enregistrements : un pour la racine (apex) et un pour www.

### 8.1 – Enregistrement pour la racine (apex)

- Name : laissez **vide** (pour ecotech-solutions.com)  
- IP address : **10.50.0.5**  
- Décochez **Create associated pointer (PTR) record**  
- Cliquez sur **Add Host**

### 8.2 – Enregistrement pour www

- Name : **www**  
- IP address : **10.50.0.5**  
- Décochez **Create associated pointer (PTR) record**  
- Cliquez sur **Add Host**, puis **Done**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6e5bb96ddcd76397b1349271cf39f8ee1e465378/components/web_ex/dns_externe/ressources/config/09_dns_configuration.jpg)

Les deux noms (racine et www) pointent vers le Reverse Proxy → c’est l’effet split-horizon recherché.


## Étape 9 – Test de résolution depuis un client interne

Sur un poste du LAN (ex. VLAN 610 ou 620) :

1. Ouvrez une invite de commandes  
2. Tapez :

        nslookup www.ecotech-solutions.com



