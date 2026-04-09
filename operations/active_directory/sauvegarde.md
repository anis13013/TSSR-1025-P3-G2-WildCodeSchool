## Sauvegarde Active Directory

Avant toute intervention ou modification importante, il est fortement recommandé de sauvegarder l'état du système. La méthode recommandée sur Windows Server est wbadmin via le System State, qui contient la base NTDS (Active Directory), SYSVOL, le registre et les fichiers de démarrage.
Installation de la fonctionnalité de sauvegarde (à faire une seule fois) :
powershellInstall-WindowsFeature Windows-Server-Backup
Lancer une sauvegarde du System State :
powershellwbadmin start systemstatebackup -backuptarget:\\10.20.30.5\Backups\AD -quiet
Vérifier les sauvegardes disponibles :
powershellwbadmin get versions

Recommandations :

Stocker les sauvegardes sur le serveur de fichiers (10.20.30.5) dans un partage dédié et protégé
Effectuer une sauvegarde après chaque modification significative (ajout d'OU, de GPO, de DC)
Conserver au minimum les 3 dernières versions
Réaliser la sauvegarde sur les deux DC pour maximiser les chances de restauration