Configuration GLPI

## 1. Vérification de l’utilisateur administrateur AD (côté Windows)

Avant de configurer la liaison LDAP, on vérifie que le compte bind existe bien dans l’annuaire.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/dfabac5dc39a48ed939f7f168b96b0b6fa6e8523/components/glpi/ressources/config/14_glpi_config.png)

Commande PowerShell : Get-ADUser -Identity Administrator  

Le compte CN=Administrator existe dans l’OU Users.

## 2. Formulaire de création d’un annuaire LDAP dans GLPI

Menu : Configuration Authentification Annuaires LDAP + (nouveau)

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/dfabac5dc39a48ed939f7f168b96b0b6fa6e8523/components/glpi/ressources/config/16_glpi_config.png)

Paramètres principaux renseignés :
- Serveur par défaut : Oui
- Actif : Oui
- Serveur : 10.20.20.5
- Port : 389
- BaseDN : DC=ecotech,DC=local
- Utiliser bind : Oui
- DN du compte bind : CN=Administrator,CN=Users,DC=ecotech,DC=local

## 3. Détails avancés du filtre et des champs de synchronisation

Onglet « Intitulés » et « Composants » du même formulaire.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/c6322174151f87547863f46c8fa57fd2ba273001/components/glpi/ressources/config/13_glpi_config.png)

Filtre de connexion :  

(&(objectClass=user)(objectCategory=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))  

Utilisateurs actifs uniquement (pas désactivés)

Champs de synchronisation :
- Identifiant GLPI ← samaccountname
- Champ de synchronisation (unique) ← objectguid

## 4. Test de la connexion LDAP

Bouton « Tester » sur la fiche de l’annuaire.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/c6322174151f87547863f46c8fa57fd2ba273001/components/glpi/ressources/config/15_glpi_config.png)

Résultat :  

**Test réussi : Serveur principal ECOTECH**  
La connexion au serveur LDAP fonctionne parfaitement.

## 5. Écran d’importation des utilisateurs

Menu : Administration -> Annuaires LDAP -> Importation de nouveaux utilisateurs

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/c6322174151f87547863f46c8fa57fd2ba273001/components/glpi/ressources/config/17_glpi_config.png)

- Mode expert activé  
- Critères de recherche par champ (samaccountname, mail, nom, prénom, téléphone, etc.)  
- Possibilité d’activer le filtrage par date de modification

## 6. Tableau de bord après première connexion (alertes sécurité)

Connexion avec le compte glpi par défaut → page d’accueil avec les avertissements classiques post-installation.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/dfabac5dc39a48ed939f7f168b96b0b6fa6e8523/components/glpi/ressources/config/11_glpi_config.png)


Alertes visibles :
- Changer les mots de passe par défaut (glpi, post-only, tech, normal)
- Supprimer le dossier /install/
- Sécuriser le dossier racine web
- Activer httpOnly pour les cookies de session

## Actions de sécurisation recommandées (à réaliser juste après l’installation)

1. Supprimer immédiatement le dossier d’installation  
   → empêche toute ré-exécution de l’installateur

2. Restreindre les droits sur le dossier de configuration  
   → chmod 640 sur les fichiers .php du dossier config

3. Changer TOUS les mots de passe par défaut  
   Comptes concernés : glpi, post-only, tech, normal

4. Passer l’instance en HTTPS  
   → même un certificat auto-signé est préférable à HTTP en clair pour un labo

5. Mettre en place une tâche planifiée (cron) pour la synchronisation LDAP  
   Exemple de commande GLPI :  

   php /var/www/html/glpi/bin/console glpi:ldap:synchronize_users --ldap-server-id=1

## Résumé – Ce qui a été réussi dans ce laboratoire

- Installation complète de GLPI 10.x  
- Connexion fonctionnelle à un Active Directory réel  
- Test LDAP validé (serveur, bind, filtre utilisateurs actifs)  
- Champs de synchronisation correctement mappés (samaccountname → identifiant, objectguid → synchro unique)  
- Première connexion et prise en main du tableau de bord

Prochaines étapes possibles pour aller plus loin :
- Importation réelle d’utilisateurs et groupes  
- Configuration des droits et profils GLPI selon l’organisation  
- Ajout de plugins (ex : FusionInventory, Formcreator)

Bon laboratoire et bonne présentation devant le professeur !
