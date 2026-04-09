# FreePBX - Phase 2 : Configuration

---


Ce fichier vous guide étape par étape dans la **phase de configuration** de votre serveur FreePBX, une fois l’installation terminée.  
Toutes les captures d’écran sont incluses pour que vous puissiez suivre visuellement chaque action.

Les étapes sont présentées dans l’ordre chronologique réel des actions que vous effectuerez.

---

### Étape 1 : Accès au Firewall depuis le Dashboard
Depuis le tableau de bord principal, cliquez sur **Connectivity** puis sur **Firewall**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/03_configuration_freepbx.jpg)

Vous arrivez sur la section Firewall.

### Étape 2 : Page principale du Firewall et Responsive Firewall
Vérifiez que le **Responsive Firewall** est activé (il l’est par défaut après le wizard initial).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/04_configuration_freepbx.jpg)

Le message vert confirme que les endpoints SIP sont automatiquement autorisés après enregistrement.  
Vous pouvez ici relancer le wizard si nécessaire ou désactiver le firewall (déconseillé).

### Étape 3 : Configuration des réseaux dans le Firewall
Allez dans l’onglet **Networks** et configurez vos réseaux locaux.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/05_configuration_freepbx.jpg)

Exemples de configuration typique :
- *Première adresse IP* → **Trusted (Excluded from Firewall)**
- *deuxième adresse IP* → **Trusted**
- Ajoutez vos autres subnets selon vos besoins !

Cliquez sur **Save** pour appliquer.

### Étape 4 : Accès à la gestion des Extensions
Retournez dans le menu principal : cliquez sur **Applications** puis sur **Extensions**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/06_configuration_freepbx.jpg)

### Étape 5 : Liste des extensions et création d’une nouvelle extension
Vous voyez la liste des extensions existantes (ici 1000 et 1001).  
Cliquez sur **+ Add Extension** → **Add New SIP [chan_pjsip] Extension**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/07_configuration_freepbx.jpg)

### Étape 6 : Formulaire de création d’une extension PJSIP
Remplissez les champs de la nouvelle extension (exemple avec l’extension 1003) :

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/08_configuration_freepbx.jpg)

Points importants :
- **User Extension** : numéro de poste (ex. 1003)
- **Display Name** : nom affiché (ex. "Nom1")
- **Secret** : mot de passe SIP (évitez les mots de passe faibles comme « 1234 » – utilisez un mot de passe complexe !)
- Cliquez sur **Submit** puis sur **Apply Config** (bouton rouge en haut à droite).

### Étape 7 : Configuration du softphone 3CXPhone (côté client Windows)
Sur votre poste de travail, ouvrez **3CXPhone** et créez/ajoutez un compte SIP.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/01_configuration_freepbx.jpg)

#### Description des champs (fenêtre Account settings)

**En tête**
- Account name : nom du profil local. Valeur libre pour identifier ce compte dans l’application (ex. Poste1, Bureau-Pierre). Utile si vous gérez plusieurs comptes/profils sur la même machine.

- Caller ID : numéro ou étiquette affichée à l’interlocuteur lors d’un appel sortant. Peut être l’extension (1000) ou le numéro principal de l’entreprise.

**Credentials (Identifiants)**

Extension : numéro d’extension SIP attribué par l’administrateur PBX (ex. 1000). C’est généralement le numéro que l’on compose en interne.

ID : identifiant SIP (souvent identique à l’extension, mais peut être différent si l’admin l’a défini ainsi). C’est le « username » SIP envoyé au serveur pour s’authentifier.

Password : mot de passe SIP (secret). Renseignez le secret fourni par l’administrateur. NE PAS committer ce mot de passe dans un dépôt public. Stockez-le dans un coffre (password manager) ou utilisez des variables d’environnement / fichiers chiffrés.

**My location**

I am in the office - local IP : cochez et saisissez l’adresse IP interne (LAN) du serveur PBX si vous êtes sur le même réseau local que le PBX (ex. 10.60.70.5). Permet au client de se connecter en adresse privée sans traverser NAT.

I am out of the office - external IP : cochez et saisissez l’IP publique ou le nom de domaine (FQDN) du PBX si vous êtes en dehors du réseau (ex. vpn.exemple.com ou 54.23.12.34). À utiliser pour les connexions via Internet / NAT.

**Use 3CX Tunnel**

Case à cocher : activer si votre installation 3CX utilise le tunnel 3CX pour traverser les pare-feux/NAT sans ouvrir les ports RTP/SIP externes. Active seulement si l’administrateur PBX l’a configuré.

Local IP of remote PBX : adresse du PBX vue localement pour le tunnel (souvent préremplie).

Tunnel password : mot de passe du tunnel fourni par l’administrateur (utile pour authentifier le tunnel).

Port (ex. 5090) : port utilisé par le service tunnel. Ne changez que si l’admin vous le demande.

Quand activer : activez le tunnel si vous avez des problèmes causés par NAT/pare-feu et que l’administrateur a fourni les informations de tunnel. Sinon laissez décoché et privilégiez TLS + SRTP quand possible.

**Use Outbound Proxy server**

Champ texte : adresse IP ou FQDN (et éventuellement port) du proxy sortant exigé par certains fournisseurs VoIP. Renseignez seulement si vous en avez besoin. (ex. proxy.voipfournisseur.com:5060).

Perform provisioning from following URL

URL de provisioning : URL fournie par l’administrateur ou l’opérateur pour provisionner automatiquement le client (format http://... ou https://...). Si vous utilisez cette URL, le client téléchargera la configuration (codec, comptes, touches rapides, etc.). Exemple : https://pbx.exemple.com/prov/1000.

**Boutons et options avancées**

Advanced settings : ouvre des paramètres détaillés (transport SIP — UDP/TCP/TLS, codecs prioritaires [G.711, G.729, opus], STUN, keep-alive, ports RTP, etc.). Renseignez ces options uniquement si vous savez ce que vous faites ou sur demande de l’admin.

Cliquez sur **OK**.

*Faite la manipulation sur chaques clients 3CX!*

### Étape 8 : Vérification finale – Softphones connectés

*Si vos téléphones affiche "Not Connected", vérifiez rapidement la connectivité réseau (Wi-Fi/câble), que l’adresse IP/FQDN du PBX est correcte et joignable, que vos identifiants SIP sont valides.

Une fois les extensions enregistrées, vos softphones doivent afficher **Connected** lorsque vous appelez les 2 postes.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/24391a8bc866ef6143271173677e8a9a0d557879/components/freepbx/ressources/configuration/02_configuration_freepbx.jpg)

Vous pouvez maintenant passer des appels internes entre les postes (composez simplement le numéro de l’autre extension).

---
