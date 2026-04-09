# Installation de l'outils PingCastle sur ECO-BDX-EX02

- Ce document précise les étapes à suivre pour l'installation et l'utilisation du logiciel PingCastle.

---

## Table des matières 

---

## Pré-requis

- Disposer d'un compte avec une **adresse e-mail professionnelle** (les adresses Gmail, Hotmail, etc. sont refusées)
- Avoir accès à **Internet** depuis le poste ou le serveur
- Disposer des **droits administrateur** sur le serveur cible

---

## Étape 1 — Télécharger PingCastle

1. Ouvrir un navigateur et accéder à l'adresse suivante :  
   **https://www.netwrix.com/en/products/pingcastle/**

2. Cliquer sur le bouton **"Get instant access"** ou **"Free Download"**

3. Renseigner votre **adresse e-mail professionnelle** dans le formulaire

4. Confirmer votre adresse si un e-mail de vérification est envoyé

5. Télécharger l'archive ZIP, par exemple :  
   `PingCastle_3.5.0.40.zip`

- **Alternative :** Le code source et les releases sont également disponibles directement sur GitHub :  
  - https://github.com/netwrix/pingcastle/releases

---

## Étape 2 — Vérifier l'intégrité du fichier (hash SHA256)

Avant d'extraire ou d'exécuter le fichier, il est recommandé de vérifier que l'archive n'a pas été corrompue ou modifiée.

- Récupérer le hash officiel
  - Sur la page de téléchargement Netwrix, copier le hash SHA256 affiché
- Calculer et comparer le hash via PowerShell
  - **Ne pas continuer si le hash est invalide.** Supprimer le fichier et recommencer le téléchargement.

---

## Étape 3 — Extraire l'archive

1. Faire un clic droit sur le fichier ZIP
2. Sélectionner **"Extraire tout..."**
3. Choisir un répertoire de destination, par exemple :  
   `C:\PingCastle\`

Le répertoire contiendra notamment les fichiers suivants :

| Fichier | Description |
|---|---|
| `PingCastle.exe` | Exécutable principal |
| `PingCastle.exe.config` | Fichier de configuration (licence) |
| `readme.md` | Documentation rapide |

---

## Étape 4 — Lancer PingCastle

1. Ouvrir une invite de commandes ou PowerShell **en tant qu'administrateur**

2. Se placer dans le répertoire d'extraction :

```powershell
cd C:\PingCastle
```

3. Lancer l'outil :

```powershell
.\PingCastle.exe
```

1. Un menu interactif s'affiche — sélectionner **1** pour lancer un audit complet du domaine.

2. À la fin de l'analyse, un fichier HTML de rapport est généré dans le même répertoire :  
   `ad_hc_<nom_du_domaine>.html`

---