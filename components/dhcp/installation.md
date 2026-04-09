# DHCP installation

-----

Ce fichier décrit les étapes et les paramètres nécessaires à l’installation d'un rôle DHCP en GUI ET CLI. 



### Serveur GUI : 

1. Dans Serveur Manager cliquez sur **"Add Roles and features"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/01_dhcp_installation.jpg)


2. Cliquez sur **"Next"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/02_dhcp_installation.jpg)



3. Laisser par default cliquez sur **Next**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/03_dhcp_installation.jpg)




4. Cliquer sur **"Select a server from the server pool"**, puis cliquez sur **"Next"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/04_dhcp_installation.jpg)




5. Cochez la case **"DHCP Server"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/05_dhcp_installation.jpg)




6. Cliquez sur **"Add features"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/06_dhcp_installation.jpg)




7. Cliquez **"Next"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/07_dhcp_installation.jpg)




8. Cliquez **"Next"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/08_dhcp_installation.jpg)




9. Cliquez **"Close"**

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/09_dhcp_installation.jpg)


**L’installation du service DHCP est désormais terminée, mais le service doit être configuré pour la distribution automatique des configurations réseaux aux clients.**

----
----

### Serveur CORE :

1.Pour installer le rôle DHCP tapez la commande :

    Install-WindowsFeature DHCP -IncludeManagementTools

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/12_dhcp_installation.jpg)

2. Pour vérifier si l'installation à bien était faite afficher le rôle DHCP en tapant la commande : 

       Install-WindowsFeature DHCP -IncludeManagementTools

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/bab2d967a9ce0ad7d0406644dfe0f4340b1f03a7/components/dhcp/ressources/install/11_dhcp_installation.jpg)

**L’installation du service DHCP est désormais terminée, mais le service doit être configuré pour la distribution automatique des configurations réseaux aux clients.**
