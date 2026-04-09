# Configuration - VyOS 

**Projet :** EcoTech Solutions
**Groupe :** 2
**OS Cible :** VyOS 1.4+
**Objectif :** Synthèse des commandes pour le déploiement des routeurs (Backbone & Cœur).

Ce document recense les commandes nécessaires pour configurer les interfaces, le routage, les services de base et (le pare-feu, qui arrive d'ici peu), ainsi que les commandes de gestion du cycle de vie de la configuration.

---
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/21b27a7025fab3dfd82126510316727acf065d8a/components/Vyos/ressources/Logo%20Vyos/background.png)

---

# Table des Matières 

 - [1) Mode Configuration](#1-mode-configuration)
   - [1.1 Configuration des Interfaces](#11-configuration-des-interfaces-niveau-2--3)
   - [1.2 Configuration du Routage](#12-configuration-du-routage-statique)
   - [1.3 Diagnostic et Vérification](#13-diagnostic-et-vérification-interface--route-statique)
   - [1.4 Système et Services de Base](#14-système-et-services-de-base-à-connaitre)
- [2) Firewalling](#2-firewalling-bases---stateless--stateful)
   - [2.1 Règles stateful](#21-règles-stateful-retour-de-connexion)
   - [2.2 Règles d'autorisation/blocage](#22-règles-dautorisation-ou-de-blocage)
   - [2.3 Application et validation](#23-appliquer-le-firewall-valider-et-sauvegarder)
- [3) Service DHCP-RELAY](#3-service-dhcp-relay)
   - [3.1 Commandes DHCP-Relay](#31-tableau-des-commandes-service-dhcp-relay-ipv4)
   - [3.2 Vérification DHCP](#32-tableau-de-vérification-service-dhcp-relay-diagnostic)
- [4.1 Validation Visuelle](#41-validation-visuelle)
- [4.2 Validation Visuelle - Routeur Backbone DX03](#42-validation-visuelle---routeur-backbone-dx03)

---
# 1) Mode Configuration 

Avant de taper ces commandes, il faut entrer en mode configuration via la commande : 
    
    configure

| Action | Commande | Description |
| :--- | :--- | :--- |
| **Entrer en config** | configure | Passe du mode utilisateur ($) au mode configuration (#). |
| **Appliquer** | commit | Applique les changements en mémoire vive (RAM). |
| **Sauvegarder** | save | Enregistre la configuration active sur le disque (persistant au reboot). |
| **Quitter** | exit | Sort du mode configuration. |
| **Annuler** | exit discard | Quitte sans sauvegarder les modifications non appliquées. |
| **Voir les modifs** | compare | Affiche les différences entre la config active et vos changements non "commités". |

---

### 1.1) Configuration des Interfaces (Niveau 2 & 3)

Remplacez [X] par le numéro de l'interface (ex: eth0, eth1) et [ID] par le VLAN.

| Objectif | Syntaxe de la commande | Exemple Concret |
| :--- | :--- | :--- |
| **IP sur Interface Physique** | set interfaces ethernet eth[X] address '[IP]/[CIDR]' | set interfaces ethernet eth0 address '10.40.20.2/28' |
| **Description** | set interfaces ethernet eth[X] description '[TEXTE]' | `set interfaces ethernet eth0 description 'UPLINK-VERS-DX03' |
| **Créer une VIF (VLAN)** | set interfaces ethernet eth[X] vif [ID] address '[IP]/[CIDR]' | set interfaces ethernet eth1 vif 210 address '10.20.10.254/24' |
| **Description VLAN** | set interfaces ethernet eth[X] vif [ID] description '[NOM]'` | set interfaces ethernet eth1 vif 210 description 'VLAN-ADMIN' |
| **Supprimer une IP** | delete interfaces ethernet eth[X] address | delete interfaces ethernet eth0 address |
| **Supprimer un VLAN** | delete interfaces ethernet eth[X] vif [ID] | delete interfaces ethernet eth1 vif 999 |

---

### 1.2) Configuration du Routage (Statique)

| Objectif | Syntaxe de la commande | Exemple Concret |
| :--- | :--- | :--- |
| **Route par défaut (Internet)** | set protocols static route 0.0.0.0/0 next-hop [IP_GW] | set protocols static route 0.0.0.0/0 next-hop 10.40.20.1 |
| **Route vers un réseau** | set protocols static route [RESEAU]/[CIDR] next-hop [IP_GW] | set protocols static route 10.60.0.0/16 next-hop 10.40.20.2 |
| **Supprimer une route** | delete protocols static route [RESEAU]/[CIDR] | delete protocols static route 0.0.0.0/0 |

---

### 1.3) Diagnostic et Vérification (Interface & Route statique)

Ces commandes se tapent en mode utilisateur (pas besoin de configure, ou utiliser run devant si vous êtes en config).

| Commande | Résultat attendu / Usage |
| :--- | :--- |
| show interfaces | Affiche la liste des cartes, VLANs, IPs et leur état (u/u = Up/Up). |
| show ip route | Affiche la table de routage (S = Static, C = Connected). |
| show ip route 0.0.0.0 | Vérifie spécifiquement la route par défaut. |
| show configuration | Affiche toute la configuration active. |
| show configuration commands | Affiche la configuration sous forme de liste de commandes set. |
| ping [IP] | Teste la connectivité vers une IP. |
| monitor interface eth[X] | Affiche le trafic en temps réel (débit) sur une interface. |

---

### 1.4) Système et Services de Base à connaitre

| Objectif | Syntaxe de la commande | Description |
| :--- | :--- | :--- |
| **Nom d'hôte** | set system host-name '[NOM]' | Définit le nom de la machine (ex: ECO-BDX-AX01). |
| **Serveur DNS** | set system name-server [IP_DNS] | Définit le DNS utilisé par le routeur (ex: 1.1.1.1). |
| **Activer SSH** | set service ssh port '22' | Active l'accès distant sécurisé. |

---

# 2) Firewalling (Bases - Stateless / Stateful)

Respecter l’ordre : définir politique → règles stateful → règles accept/drop → appliquer → commit → save.

### 2.1) Définir la politique du firewall

| **Étape** | **Commande généralisée**                                        | **Fonctionnalité / Explication**                                                               | **Remarques / prérequis**                                                   |
| --------: | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
|         1 | set firewall name <FW_NAME> default-action drop              | Fixe l’action par défaut pour tout trafic ne correspondant à aucune règle : ici blocage total. | Toujours la première étape pour respecter le principe du moindre privilège. |
|         2 | (optionnel) set firewall name <FW_NAME> default-action accept | Fixe la politique par défaut pour autoriser tout trafic non filtré.                            | Rarement utilisé en production ; généralement pour tests.                   |


### 2.2) Règles stateful (retour de connexion)

| **Étape** | **Commande généralisée**                                      | **Fonctionnalité / Explication**                                                            | **Remarques / prérequis**                                                                  |
| --------: | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
|         1 | set firewall ipv4 name <FW_NAME> rule <N> state established | Autorise les paquets appartenant à des connexions déjà établies (réponses).                 | Placer en priorité haute dans les règles pour permettre le retour des flux légitimes.      |
|         2 | set firewall ipv4 name <FW_NAME> rule <N> state related     | Autorise les paquets considérés liés à une connexion existante (ex : flux complémentaires). | Complète la fonctionnalité stateful. Numérotation <N> souvent juste après `established`. |


### 2.3) Règles d’autorisation ou de blocage

| **Étape** | **Commande généralisée**                                                  | **Fonctionnalité / Explication**                                     | **Remarques / prérequis**                                                  |
| --------: | ------------------------------------------------------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------- |
|         1 | set firewall ipv4 name <FW_NAME> rule <N> action accept                 | Permet le passage des paquets correspondant aux critères définis.    | À placer avant les règles de blocage si nécessaire.                        |
|         2 | set firewall ipv4 name <FW_NAME> rule <N> action drop                  | Bloque le trafic.                              | Utile pour bloquer explicitement certains flux malgré le default-action. |
|         3 | set firewall ipv4 name <FW_NAME> rule <N> protocol <nom protocol>      | Déclaré le protocol définit dans "<nom protocol>"
|         4 | set firewall ipv4 name <FW_NAME> rule <N> description "<texte>"        | Documente la règle avec une description lisible.                     | Important pour maintenance et relecture.                                   |
|         5 | set firewall ipv4 name <FW_NAME> rule <N> destination address <IP/CIDR>| Restreint l’application de la règle à certaines adresses ou réseaux. | Permet un filtrage fin par destination.                                    |

**Exemple :**

    La régle en entier
    set firewall name METIERS_TO_AD rule 20 action accept
    set firewall name METIERS_TO_AD rule 20 description 'Autoriser ICMP (ping) vers AD'
    set firewall name METIERS_TO_AD rule 20 protocol icmp

    -------------------------------------------------------------------------

    # Pour AUTORISER :
    set firewall name METIERS_TO_AD rule 20 action accept

    # Pour BLOQUER :
    set firewall name METIERS_TO_AD rule 20 action drop

    ------------------------------------------------------------------------

    set firewall name METIERS_TO_AD rule 20 action accept    # ← la décision
    set firewall name METIERS_TO_AD rule 20 protocol icmp     # ← le critère



### 2.4) Appliquer le firewall, valider et sauvegarder

| **Étape** | **Commande généralisée**                                           | **Fonctionnalité / Explication**                                                   | **Remarques / prérequis**                                          |
| --------: | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
|         1 | set interfaces ethernet <if> vif <ID> firewall in name <FW_NAME> | Applique le firewall à l’interface VLAN pour filtrer le trafic entrant.            | Répéter pour chaque VLAN concerné.                                 |
|         2 | commit                                                           | Charge et applique la configuration dans le système en cours.                      | Nécessaire avant de sauvegarder ; valide toutes les modifications. |
|         3 | save                                                             | Sauvegarde la configuration sur le stockage pour qu’elle survive aux redémarrages. | Toujours après commit.                                           |


---


# 3) Service DHCP-RELAY

### But et principe rapide

Le DHCP relay permet au routeur VyOS de rediriger les requêtes DHCP reçues sur des sous-réseaux locaux vers un/des serveurs DHCP centralisés (IPv4 et IPv6 supportés). Toutes les interfaces impliquées (interfaces d’écoute et l’interface vers le(s) serveur(s)) doivent être listées dans la configuration du relay.

### 3.1) Tableau des commandes service dhcp-relay (IPv4)
| **Commande**                                                        | **Fonctionnalité**             | **À quoi ça sert concrètement**                           | **Remarques / Bonnes pratiques**                                                  |
| ------------------------------------------------------------------- | ------------------------------ | --------------------------------------------------------- | --------------------------------------------------------------------------------- |
| set service dhcp-relay                                            | Active le service DHCP Relay   | Permet à VyOS d’agir comme agent relais DHCP              | Le service ne fonctionne que si au moins une interface et un serveur sont définis |
| set service dhcp-relay listen-interface <interface>               | Interface d’écoute DHCP        | Reçoit les requêtes DHCP des clients (broadcast)          | À configurer sur les interfaces VLAN / LAN où se trouvent les clients             |
| set service dhcp-relay upstream-interface <interface>             | Interface vers le serveur DHCP | Envoie les requêtes DHCP vers le serveur distant          | **Fortement recommandé** de la déclarer explicitement                             |
| set service dhcp-relay server <IP>                                | Serveur DHCP cible             | Adresse IP du serveur DHCP recevant les requêtes          | Peut être définie plusieurs fois pour la redondance                               |
|set service dhcp-relay relay-options hop-count <0-255>            | Limite de sauts DHCP           | Empêche les boucles infinies de relay                     | Valeur par défaut : **10**                                                        |
| set service dhcp-relay disable                                    | Désactivation du service       | Coupe complètement le DHCP Relay                          | Utile en phase de test                                                            |

### 3.2) Tableau de vérification service dhcp-relay (diagnostic)
| **Commande**                           | **Objectif**                     |                           |
| -------------------------------------- | -------------------------------- | ------------------------- |
| show service dhcp-relay              | Vérifier la configuration active |                           |
| restart dhcp relay-agent             | Redémarrer le service            |                           |
| ping <IP_DHCP>                       | Tester l’accès au serveur DHCP   |                           |
| tcpdump -i <interface> port 67 or 68` | Observer les requêtes DHCP       |                           |
| show log                              | match dhcp`                      | Vérifier les erreurs DHCP |


---
---

## 4 Validation Visuelle - Switch L3 Core AX01

Cette section illustre l'état du routeur **AX01 (Cœur-L3)** une fois la configuration appliquée. Sur le Projet 3 réalisé par le Groupe 2.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/59fb98e20398b73df28ac2145234b417a611e4f6/components/Vyos/ressources/Logo%20Vyos/Firefly_Macro%20photography%20of%20a%20sleek%20enterprise%20rack-mounted%20router%20in%20a%20server%20room.%20On%20the%20%20746892.png)

### 4.1 État des Interfaces (VLANs et Adressage)

Commande :
          
    show interfaces

Ici, nous vérifions que toutes les sous-interfaces (VIF) sont bien créées, possèdent les bonnes adresses IP (Passerelles) et sont dans l'état u/u (Up/Up).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/8cd81d36f4a40859ca4cb481dff096e0142d667a/components/vyos/ressources/DX04/01_vyos_configuration.jpg)

*Vérification : S'assurer que les VLANs 200, 210, 220, 600, etc. sont bien listés sous eth1.*

### 4.2 Table de Routage (Connectivité L3)

Commande : 
            
    show ip route

Cette capture valide le routage statique. Nous devons voir les réseaux connectés (C) et surtout la route par défaut (S) vers le Backbone.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/9f90ca04b09a19e27be5074ae3093cfaa3c78cdf/components/vyos/ressources/DX04/02_vyos_configuration.jpg.png)

*Note : Présence d'une route statique pour le VLAN 680 `10.80.60.0/24 [1/0] via 10.40.10.1, eth0`, il correspond au réseau VPN présent dans le pare-feu.*
*Vérification : Présence de la ligne `S>* 0.0.0.0/0 [1/0] via 10.40.20.1, eth0`.*

### 4.3 État des interfaces du service dhcp-relay

Cette section illustre l'état du service dhcp-relay sur **AX01 Server-Core**. Sur le Projet 3 réalisé par le Groupe 2.

Commande : 

    show service dhcp-relay

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/8cd81d36f4a40859ca4cb481dff096e0142d667a/components/vyos/ressources/DX04/03_vyos_configuration.jpg)

*Listen-interfaces - Le relais écoute les requêtes (DHCPDISCOVER) sur les interfaces vif :eth1.600, eth1.610, eth1.620, eth1.630, eth1.640, eth1.650, eth1.660, eth1.670.**

*Server 10.20.20.8 - Toutes les requêtes interceptées sont transférées à l'adresse IP 10.20.20.8.*

*Upstream-interface eth1.220 - L'interface "eth1.220" est désignée comme l'interface de sortie. Par ce VLAN que le routeur communique avec le serveur DHCP pour lui relayées/recevoir les offres de configurations réseaux.*

La configuration du service DHCP relay sur VyOS 1.5, avec plusieurs interfaces VLAN (eth2.xxx) configurées pour relayer les requêtes DHCP des différents réseaux. Le relay redirige les demandes vers deux serveurs DHCP (10.20.20.5 et 10.20.20.6). Ces deux serveurs fonctionnent en full-over (répartition de charge / load balancing ) afin d’assurer la haute disponibilité et le partage de la charge des attributions d’adresses IP. La documentation des serveurs Dhcp est présent ici [DHCP](./../../components/dhcp/README.md)

### 4.4 État du services firewall
*La configuration actuel de ce service dépendra des circonstances du projet, elle pourra donc évolué, être supprimé celon l'avancé du projet*

La configuration du firewall faite va limiter le trafic des VLANs métiers vers la VLAN serveurs 10.20.20.0/27 en bloquant tout par défaut et en n'autorisant que les communications essentielles, même si cette VLAN contient d'autres éléments. On regroupe les VLANs métiers dans un groupe pour appliquer uniformément les règles, on redirige leur trafic vers une chaîne dédiée, et on ouvre uniquement les ports nécessaires pour l'AD par exemple, évitant ainsi d'exposer les autres services potentiels de la VLAN serveurs. Cela assure une sécurité stricte en ne laissant passer que le minimum vital.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/c72a4b69bf9b6e90d0c0c1c74dfdf0b282b79e42/components/vyos/ressources/DX04/05_vyos_configuration.png)
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/c72a4b69bf9b6e90d0c0c1c74dfdf0b282b79e42/components/vyos/ressources/DX04/06_vyos_configuration.png)
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/c72a4b69bf9b6e90d0c0c1c74dfdf0b282b79e42/components/vyos/ressources/DX04/04_vyos_configuration.jpg)

Voici le tableau qui explique la mise en place faite concrête pour le service du firewall AX01 : 

| Étape | Ce qui est fait | En langage simple | Pourquoi c’est important |
|-------|------------------|-------------------|---------------------------|
| 1 | Création du groupe METIERS_GROUP | On regroupe tous les VLANs métiers (600 à 660) ensemble | Pour gérer les règles sur plusieurs réseaux sans les répéter à chaque fois |
| 2 | Règle de redirection (jump) dans le forward | Le trafic des VLANs métiers est envoyé vers la liste de règles « METIERS_TO_AD » | C’est le point de contrôle qui vérifie tout ce qui va vers la VLAN serveurs |
| 3 | Comportement par défaut | Tout trafic est bloqué sauf ce qu’on autorise explicitement | Pour protéger la VLAN serveurs en n’ouvrant que ce qui est vraiment utile à AD |
| 4 | Règles established / related et drop invalid | On accepte les réponses aux connexions en cours + on ignore les paquets suspects | Permet aux échanges normaux de continuer sans ouvrir de portes inutiles |
| 5 | Règle 10 – DNS (port 53) | Autorise la résolution de noms (trouver les adresses des serveurs) | Essentiel pour que les machines des VLANs métiers localisent les services AD |
| 6 | Règle 20 – Kerberos (ports 88, 464) | Autorise les connexions sécurisées (comme les logins) | Nécessaire pour l’authentification des utilisateurs dans le domaine AD |
| 7 | Règle 30 – LDAP / LDAPS (ports 389, 636, 3268, 3269) | Autorise l’accès à l’annuaire des utilisateurs et groupes | Permet de consulter ou modifier les infos AD sans exposer d’autres services |
| 8 | Règle 40 – SMB / RPC (ports 135, 445) | Autorise les partages de fichiers et communications basiques Windows | Utilisé pour les politiques de groupe et les accès réseau limités à AD |
| 9 | Règle 50 – Ports dynamiques RPC (49152–65535) | Autorise les ports temporaires pour les fonctions avancées Windows | Obligatoire pour que les opérations AD complexes fonctionnent sans tout ouvrir |
| 10 | Règle 60 – NTP (port 123) | Autorise la mise à l’heure des machines | L’heure synchronisée est critique pour la sécurité et le bon fonctionnement d’AD |



---



---

## 5. Validation Visuelle - Routeur Backbone DX03


Cette section illustre l'état du routeur **DX03 (Backbone)** une fois la configuration appliquée. Sur le Projet 3 réalisé par le Groupe 2.


### 5.1 État des Interfaces (Transits)

  Commande : 
       
    show interfaces

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/981c6b405cbfea27c9a7aa7b4483126ff8976595/components/vyos/ressources/DX03/01_vyos_configuration.jpg)

*Ici, on vérifie simplement les deux pattes du routeur. Contrairement au AX01, il ne doit pas y avoir de VLANs (pas de .200, .600, etc.), juste les interfaces physiques.*

*Vérification attendue :*

    eth0 : 10.40.10.2/28 (Côté PfSense) - État u/u

    eth1 : 10.40.20.1/28 (Côté Cœur AX01) - État u/u

### 5.2 Table de Routage (Le point critique)

 Commande : 
             
             show ip route

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/981c6b405cbfea27c9a7aa7b4483126ff8976595/components/vyos/ressources/DX03/02_vyos_configuration.jpg)


*Vérification attendue :*

    S>* 0.0.0.0/0 via 10.40.10.1 (Route vers Internet via PfSense).

    S>* 10.20.0.0/16 via 10.40.20.2 (Route de retour vers Infra via AX01).

    S>* 10.60.0.0/16 via 10.40.20.2 (Route de retour vers Métiers via AX01).

----















