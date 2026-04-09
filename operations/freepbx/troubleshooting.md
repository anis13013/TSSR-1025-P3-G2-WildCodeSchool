# FreePBX - Résolution des Problèmes Courants


Ce document vous aide à résoudre les problèmes les plus courants rencontrés sur un serveur FreePBX. Chaque incident est décrit avec ses symptômes, ses causes potentielles et les étapes de résolution pas à pas. Si un problème persiste, consultez les logs ou contactez le support Sangoma.

---

### 1. Avertissement « Weak Secrets » sur le Dashboard

**Symptôme :** Message rouge indiquant que des extensions ou trunks ont des mots de passe faibles.  
**Causes :** Mots de passe trop simples (ex. « 1234 » ou identiques au numéro d’extension).  
**Résolution :**  
1. Allez dans **Applications → Extensions** (ou **Connectivity → Trunks** si concerné).  
2. Éditez l’extension ou trunk en question.  
3. Changez le **Secret** pour un mot de passe fort (au moins 12 caractères, mélange de lettres, chiffres et symboles).  
4. Cliquez sur **Submit** puis sur **Apply Config** (bouton rouge en haut).  
5. Vérifiez que l’avertissement disparaît du Dashboard.

---

### 2. Extension ne s’enregistre pas (Softphone « Not Connected »)

**Symptôme :** Le softphone (ex. 3CXPhone) n’arrive pas à se connecter à l’extension.  
**Causes :** Erreur de configuration, firewall bloquant, ou réseau.  
**Résolution :**  
1. Vérifiez les paramètres du softphone : extension, mot de passe, IP du serveur (10.60.70.5).  
2. Dans FreePBX, allez dans **Applications → Extensions** et confirmez le **Secret**.  
3. Vérifiez le firewall : **Connectivity → Firewall → Networks** – assurez-vous que votre IP est en **Trusted**.  
4. En console SSH, exécutez asterisk -rx "pjsip show endpoints" pour vérifier le statut de l’extension.  
5. Si bloqué, relancez Asterisk avec fwconsole restart.  

---

### 3. Impossible d’accéder à l’interface web

**Symptôme :** Erreur de connexion à http://10.60.70.5/admin (page non trouvée ou timeout).  
**Causes :** Serveur arrêté, firewall, ou problème réseau.  
**Résolution :**  
1. Ping l’IP du serveur depuis votre poste avec ping 10.60.70.5.  
2. Vérifiez que le serveur est allumé et connecté.  
3. En SSH, vérifiez les services avec systemctl status httpd et fwconsole status.  
4. Redémarrez les services avec systemctl restart httpd et fwconsole restart.  
5. Si firewall en cause, ajoutez votre IP en **Trusted** via l’interface ou en console.

---

### 4. Appels internes ne passent pas

**Symptôme :** Composition du numéro interne n’aboutit pas (tonalité occupée ou erreur).  
**Causes :** Extensions non enregistrées, règles de routage manquantes, ou DND activé.  
**Résolution :**  
1. Vérifiez que les extensions sont enregistrées avec asterisk -rx "pjsip show endpoints".  
2. Assurez-vous qu’aucune option DND ou Call Forward n’est active dans **Applications → Extensions**.  
3. Vérifiez les logs pour les erreurs avec tail -f /var/log/asterisk/full.  
4. Relancez la configuration avec fwconsole reload.  

---

### 5. Firewall bloque les connexions SIP

**Symptôme :** Enregistrements échouent malgré des paramètres corrects.  
**Causes :** Règles firewall trop restrictives ou IP non trusted.  
**Résolution :**  
1. Allez dans **Connectivity → Firewall → Networks**.  
2. Ajoutez votre réseau/subnet en **Trusted (Excluded from Firewall)**.  
3. Sauvegardez et appliquez.  
4. Vérifiez les logs firewall avec tail -f /var/log/secure.  
5. Si nécessaire, relancez le wizard firewall en cliquant sur **Re-Run Wizard**.

---

### 6. Bouton « Apply Config » reste rouge

**Symptôme :** Le bouton rouge n’apparaît pas ou persiste après clic.  
**Causes :** Modifications en attente ou erreur de module.  
**Résolution :**  
1. Cliquez sur le bouton rouge **Apply Config**.  
2. Si persistant, vérifiez les modules avec fwconsole ma list.  
3. Rechargez la configuration avec fwconsole reload.  

---

Ces étapes couvrent la majorité des incidents courants. Pour des problèmes plus complexes, analysez les logs ou consultez la communauté FreePBX.
