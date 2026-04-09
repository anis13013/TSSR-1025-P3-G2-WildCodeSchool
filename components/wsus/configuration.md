# 1. Configuration du serveur WSUS ECO-BDX-EX16

Cette **Partie A** présente de façon complète et ordonnée toute la configuration réalisée directement sur le serveur Windows Server Update Services (WSUS) nommé **ECO-BDX-EX16**.  
Chaque étape est illustrée par les captures d’écran correspondantes. Les explications indiquent clairement ce qui a été fait et pourquoi ce choix est pertinent dans un environnement d’entreprise.

## 1.1. État initial de la console WSUS

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)

La console s’ouvre sur une vue vide avec le statut « Idle » et le message indiquant qu’aucune synchronisation n’a encore eu lieu.  
C’est le point de départ classique d’une installation fraîche. L’administrateur lance alors l’assistant de configuration pour définir tous les paramètres de base.

## 1.2. Lancement de l’assistant de configuration

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_02.jpg)

L’administrateur clique sur **Options** puis sur le lien « WSUS Server Configuration Wizard ».  
Cet assistant officiel permet de configurer les réglages essentiels de manière guidée et fiable.

## 1.3. Pages initiales de l’assistant

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_04.jpg)  

Le choix « Synchronize from Microsoft Update » est sélectionné (connexion directe). Aucun proxy n’est configuré car l’accès internet est direct. Le bouton « Start Connecting » lance la récupération des métadonnées depuis Microsoft.

## 1.4. Choix des produits et classifications

Seules les langues **English** et **French** sont conservées.  
Cette sélection réduit considérablement l’espace disque utilisé par les fichiers de mises à jour.  
  
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_06.jpg)  
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_07.jpg)  
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_08.jpg)  
  
Toutes les versions Windows 10 et Windows 11 Client ainsi que les systèmes serveurs 21H2 à 23H2 sont sélectionnées.  
Le serveur peut ainsi distribuer les mises à jour à l’ensemble du parc postes de travail et serveurs de l’entreprise.  

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_09.jpg)

Seules les catégories **Critical Updates** et **Security Updates** sont activées.  
Ce choix priorise la sécurité et évite le téléchargement de mises à jour optionnelles inutiles.

## 1.5. Planning de synchronisation et fin de l’assistant

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_10.jpg)  

La synchronisation est configurée en mode automatique (une fois par jour). La case « Begin initial synchronization » est cochée.  
L’assistant se termine et la première synchronisation se lance automatiquement.

## 1.6. Première synchronisation en cours

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_11.jpg)  

Le statut passe à « Synchronizing… » puis « Running… ».  
Cette phase correspond au téléchargement réel des mises à jour depuis Microsoft Update.

## 1.7. Configuration manuelle via le menu Options
  
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_13.jpg)  
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_14.jpg)  
![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_20.jpg)  
  
Les groupes d’ordinateurs **Clients**, **DC** et **Servers** sont créés.  
Cette organisation permet de définir des règles différentes selon le type de machine.

# 2. Configuration des GPO

Cette partie se concentre exclusivement sur la configuration des stratégies de groupe (GPO) côté client.  
L’objectif est de faire en sorte que tous les ordinateurs du domaine se connectent automatiquement au serveur WSUS **ECO-BDX-EX16**, s’assignent au bon groupe et appliquent les mises à jour selon un planning défini.  
Chaque capture d’écran est expliquée pour que les étudiants puissent reproduire ces étapes et que le professeur dispose d’un support visuel clair et pédagogique.  

## 2.1. Pointage vers le serveur WSUS intranet

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_21.jpg)  

La stratégie **Specify intranet Microsoft update service location** est activée (Enabled).  
Les deux champs sont renseignés avec la même URL : `http://ECO-BDX16.ecotech.local:8530`

**Rôle de cette stratégie** : elle indique à tous les ordinateurs Windows du domaine d’utiliser le serveur WSUS interne au lieu de se connecter directement à Microsoft Update sur internet.  
C’est l’étape fondamentale pour centraliser les mises à jour.

## 2.2. Activation du client-side targeting (assignation au groupe)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_25.jpg)  

La stratégie **Enable client-side targeting** est mise sur **Enabled**.  
Le champ **Target group name for this computer** contient la valeur **Clients**.  

**Rôle de cette stratégie** : elle permet à chaque ordinateur client de s’identifier automatiquement auprès du WSUS en indiquant dans quel groupe il doit être placé (ici le groupe « Clients » créé sur le serveur WSUS).  
Cela facilite l’application de règles spécifiques par groupe (approbations, délais, etc.).

## 2.3. Configuration des mises à jour automatiques

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_27.jpg)  

La stratégie **Configure Automatic Updates** est activée avec l’option **4 – Auto download and schedule the install**.  
Paramètres sélectionnés :  
- Installation tous les jours  
- Horaire d’installation : **03:00**  

**Rôle de cette stratégie** : elle force les ordinateurs à télécharger automatiquement les mises à jour approuvées par le WSUS et à les installer selon un planning fixe (chaque jour à 3h du matin).  
Ce réglage garantit une application régulière, silencieuse et sans intervention des utilisateurs.

# 3. Configuration des GPO Client pour le groupe DC

**Guide pédagogique – Configuration côté client uniquement (serveurs Domain Controllers)**  

Les captures montrent les réglages appliqués pour les DC, qui diffèrent légèrement de ceux des postes clients classiques.

## 3.1. Pointage vers le serveur WSUS intranet (identique pour tous)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)  

La stratégie **Specify intranet Microsoft update service location** est activée (Enabled).  
Les deux champs (update service et statistics server) pointent vers :  `http://ECO-BDX-EX16.ecotech.local:8530`  

**Rôle** : tous les ordinateurs du domaine, y compris les Domain Controllers, utilisent le serveur WSUS local au lieu de Microsoft Update sur internet.  

## 3.2. Activation du client-side targeting pour les DC

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)  

La stratégie **Enable client-side targeting** est mise sur **Enabled**.  
Le champ **Target group name for this computer** contient la valeur **DC**.  

**Rôle** : cette stratégie permet aux Domain Controllers de s’identifier automatiquement auprès du WSUS en indiquant qu’ils appartiennent au groupe **DC** (créé précédemment sur le serveur WSUS).  
Cela permet d’appliquer des règles spécifiques aux contrôleurs de domaine (approbations plus strictes, planning différent, etc.).  

## 3.3. Configuration des mises à jour automatiques pour les DC

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)  

La stratégie **Configure Automatic Updates** est activée avec l’option **3 – Auto download and notify for install**.  

**Rôle** :  
- Les mises à jour sont téléchargées automatiquement en arrière-plan.  
- Une notification est envoyée à l’utilisateur (administrateur) lorsqu’elles sont prêtes à être installées.  
- L’installation n’est pas automatique : elle nécessite une intervention manuelle ou une approbation explicite.  

**Pourquoi ce choix pour les DC ?**  
Les Domain Controllers sont des machines critiques. Une installation automatique pendant la nuit pourrait causer un redémarrage imprévu et perturber l’authentification du domaine.  
L’option 3 offre un contrôle plus strict : les administrateurs sont informés et décident du moment de l’installation.

**Paramètres supplémentaires observés** :  
- Pas de case cochée pour « Install during automatic maintenance » (pas d’installation forcée).  
- Pas de planning fixe d’installation automatique (contrairement aux postes clients qui utilisent l’option 4 à 03:00).  

Ce réglage est adapté aux serveurs critiques : il garantit que les mises à jour de sécurité arrivent rapidement, tout en laissant le contrôle final aux administrateurs pour éviter tout risque sur les contrôleurs de domaine.

**Prochaines étapes pour le cours :**  
1. Créer une GPO dédiée aux DC (ou utiliser un filtre WMI / lien spécifique sur l’OU Domain Controllers)  
2. Forcer la mise à jour des stratégies sur un DC test (gpupdate /force)  
3. Vérifier dans la console WSUS que les DC apparaissent dans le groupe **DC** et rapportent leur statut

# Configuration des GPO Client pour le groupe Serveurs

Cette section poursuit la **Partie B** en présentant les stratégies de groupe (GPO) appliquées spécifiquement aux **serveurs généraux** (groupe **Serveurs** sur le WSUS).  
L’approche reste cohérente avec les précédentes configurations (pointage WSUS + targeting), mais le planning d’installation est adapté aux serveurs non critiques (contrairement aux Domain Controllers).

Les captures montrent les réglages finaux pour ce groupe.

## 1. Pointage vers le serveur WSUS intranet (identique pour tous les groupes)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)  

La stratégie **Specify intranet Microsoft update service location** est activée (Enabled).  
Les deux champs pointent vers :  `http://ECO-BDX-EX16.ecotech.local:8530`

**Rôle** : tous les serveurs du domaine utilisent le serveur WSUS interne au lieu de se connecter directement à Microsoft Update sur internet.

## 2. Activation du client-side targeting pour les serveurs

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)  

La stratégie **Enable client-side targeting** est mise sur **Enabled**.  
Le champ **Target group name for this computer** contient la valeur **Serveurs**.  

**Rôle** : cette stratégie permet aux serveurs généraux de s’identifier automatiquement auprès du WSUS en indiquant qu’ils appartiennent au groupe **Serveurs**.  
Cela permet d’appliquer des règles d’approbation et de planning spécifiques à ce type de machines (différentes de celles des postes clients ou des DC).

## 3. Configuration des mises à jour automatiques pour les serveurs

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/ec181d58c9cba8f83f9fea10658db98089b20d8d/components/wsus/ressources/config_01.jpg)  

La stratégie **Configure Automatic Updates** est activée avec l’option **3 – Auto download and notify for install**.  

**Rôle** :  
- Les mises à jour sont téléchargées automatiquement en arrière-plan.  
- Une notification est envoyée lorsqu’elles sont prêtes à être installées.  
- L’installation reste manuelle ou nécessite une approbation explicite (pas de redémarrage forcé).  

**Pourquoi ce choix pour les serveurs généraux ?**  
Les serveurs non-DC sont souvent critiques pour les applications métier. L’option 3 évite les redémarrages imprévus tout en garantissant que les mises à jour arrivent rapidement.  
Les administrateurs peuvent planifier l’installation pendant une fenêtre de maintenance.

**Comparaison avec les autres groupes** :  
- Postes clients → Option 4 (installation automatique à 03:00)  
- Domain Controllers → Option 3 (notification stricte)  
- Serveurs généraux → Option 3 (contrôle humain conservé)

**Prochaines étapes pour le cours :**  
1. Lier les GPO aux OU correspondantes (OU Clients, OU Domain Controllers, OU Serveurs)  
2. Forcer la mise à jour des stratégies sur des machines test (`gpupdate /force`)  
3. Vérifier dans la console WSUS que les ordinateurs apparaissent dans les groupes corrects et rapportent leur statut  
