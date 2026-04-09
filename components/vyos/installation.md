## 1. Présentation

Ce fichier contient un guide détaillé pour l'installation et la mise en œuvre de VyOS. Vous y trouverez les instructions étape par étape pour configurer l'image ISO, préparer l'environnement de virtualisation (ou le matériel physique) et finaliser l'installation via l'utilitaire install image.


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/21b27a7025fab3dfd82126510316727acf065d8a/components/Vyos/ressources/Logo%20Vyos/background.png)



## 2. Démarrage sur l’image VyOS

Ces étapes correspond au lancement de la machine à partir de l’image ISO de VyOS. Le système démarre en mode live, ce qui permet d’accéder à VyOS sans installation préalable sur le disque.
Vérifier que l’image VyOS démarre correctement
Accéder à l’environnement VyOS pour préparer l’installation


### Etape 1 : 

- 1] Pour se connecter tapez dans 

     Login :
  
      vyos
  
     Password :

      vyos

- 2] Tapez la commande :

      install image

- 3] Tapez le mot :

      yes
 
- 4] Appuyez sur la touche "ENTRÉE"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM1.png)

### Etape 2 : 

- 5] Appuyez sur la touche "ENTRÉE"
- 6] Tapez le mot :

      Yes

- 7] Appuyez sur la touche "ENTRÉE"
- 8] Appuyez sur la touche "ENTRÉE"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM2.png)

### Etape 3 :

- 9] Appuyez sur la touche "ENTRÉE"
- 10] Tapez le mot de passe de l'utilisateur qui se nomme "vyos"

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/6b7efea00d65165844e0aac3dbf46e8606e095b2/components/Vyos/ressources/installation/VM3.png)

### Etape 4 : 

- 11] Retapez le mot de passe attribuer à l'utilisateur "vyos"
- 12] Appuyez sur la touche "ENTRÉE"
- 13] Tapez la commande :

      reboot

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/34f85da888a0e308d87af1dde0fbbf0bc4f4edcc/components/Vyos/ressources/installation/VM4.png)

### Etape 5 : 

- 14] Tapez la lettre :

      y

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/34f85da888a0e308d87af1dde0fbbf0bc4f4edcc/components/Vyos/ressources/installation/vm5.png)

**Après le redémarrage, vous devez vous connecter au système VyOS avec le compte d'utilisateur "vyos" et le mot de passe définis lors de la phase d’installation.**

