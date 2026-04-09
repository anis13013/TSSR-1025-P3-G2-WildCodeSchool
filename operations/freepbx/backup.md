# FreePBX - Procédures de Sauvegarde et Restauration

Ce fichier vous présente les procédures recommandées pour sauvegarder et restaurer votre serveur FreePBX. Une sauvegarde régulière est essentielle pour protéger votre configuration, vos extensions, vos trunks et vos enregistrements.

### 1. Activation du module Backup (si non installé)

1. Connectez-vous à l’interface FreePBX (http://10.60.70.5/admin)
2. Allez dans **Admin → Module Admin**
3. Recherchez **Backup**
4. Installez et activez le module si nécessaire
5. Cliquez sur **Apply Config**

### 2. Création d’une sauvegarde manuelle

1. Allez dans **Admin → Backup & Restore**
2. Cliquez sur **+ Add Backup**
3. Remplissez les champs :
   - **Backup Name** : Backup_Quotidien
   - **Description** : Sauvegarde complète quotidienne
   - Cochez **All** dans la section Items to Backup
4. Dans l’onglet **Schedule**, configurez une exécution automatique (ex. tous les jours à 2h)
5. Cliquez sur **Submit** puis **Apply Config**

### 3. Exécution manuelle d’une sauvegarde

1. Dans **Backup & Restore**, cliquez sur le bouton **Run** à côté de votre sauvegarde
2. Attendez la fin du processus (le statut passe à « Completed »)

### 4. Téléchargement et stockage des sauvegardes

Les fichiers de sauvegarde sont stockés dans :  
/var/spool/asterisk/backup/

Vous pouvez les télécharger directement depuis l’interface ou via SCP :
      
      scp root@10.60.70.5:/var/spool/asterisk/backup/*.tar.gz /chemin/local/
