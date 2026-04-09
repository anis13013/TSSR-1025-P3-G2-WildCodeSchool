# Installation du rôle WSUS

**Les étapes à suivre :**
    
  1. Ouvrer le **Gestionnaire de serveur**.
  2. Cliquer sur **Ajouter des rôles et des fonctionnalités**.
  3. Cocher le rôle **Services de mise à jour Windows Server (WSUS)**. Il va automatiquement ajouter les dépendances requises (comme le serveur web IIS).

		![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/b8ed49cb8c3f7e634c6a859ca87d87e5f4d3530a/components/wsus/ressources/install_1.png)

  4. Lors de l'étape "Services de rôle", laisser cochés **WID Connectivity** et **WSUS Services**.

		![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/b8ed49cb8c3f7e634c6a859ca87d87e5f4d3530a/components/wsus/ressources/install_2.png)

  5. À l'étape "Sélectionner l'emplacement du contenu", cocher la case pour stocker les mises à jour (localement ou non) et indiquer le chemin (par exemple `D:\WSUS`).

		![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/b8ed49cb8c3f7e634c6a859ca87d87e5f4d3530a/components/wsus/ressources/install_3.png)

Une fois l'installation terminée, une notification dans le Gestionnaire de serveur avec un lien cliquable : **"Lancer les tâches de post-installation"**. Cliquer dessus pour que WSUS crée sa base de données et ses dossiers.
