## Debug & Dépannage – Problèmes courants lors de l’ajout d’un contrôleur de domaine secondaire

Cette section recense les incidents les plus fréquemment rencontrés lors de l’installation et de la promotion d’ECO-BDX-EX02 comme second contrôleur de domaine, ainsi que les étapes de diagnostic et de résolution associées. Les problèmes sont classés par phase (pré-promotion, pendant la promotion, post-promotion).

### Problèmes de pré-promotion (avant lancement de l’assistant AD DS)

**Symptôme 1 :** Impossible de joindre le domaine ecotech.local lors de l’ajout à un domaine existant (avant même la promotion).  
**Message typique :** « Le domaine ecotech.local n’a pas pu être contacté » ou « Une erreur s’est produite lors de la vérification du nom d’utilisateur/mot de passe ».  
**Causes probables :**
- DNS mal configuré (l’hôte pointe vers une passerelle publique ou un DNS externe au lieu du DC existant).
- Firewall bloquant les ports AD.
- Nom d’hôte non conforme ou non résolu correctement.
- Compte utilisé non membre de Domain Admins (ou Enterprise Admins pour la forêt).

**Étapes de diagnostic :**
1. Vérifier les paramètres DNS statiques :  
   → Propriétés IPv4 → DNS préféré = IP du DC principal.  
   → DNS alternatif = 127.0.0.1.  
   Exécuter : `ipconfig /all` et `nslookup ecotech.local` (doit résoudre vers IP des DC existants).
2. Tester la résolution et la connectivité :  
   ```powershell
   nslookup ecotech.local
   ping ecotech.local
   ```
3. Vérifier le compte :  
   ```powershell
   whoami /all   # Doit montrer appartenance à Domain Admins
   ```

**Résolution type :**
- Corriger les DNS → Pointer exclusivement vers DC existant.
- Redémarrer le service Netlogon : `Restart-Service Netlogon`.
- Si persistant : Déjoindre du domaine, redémarrer, rejoindre à nouveau, puis relancer l’installation AD DS.

### Problèmes pendant la promotion (assistant Server Manager ou PowerShell)

**Symptôme 1 :** Échec de la promotion avec « Un contrôleur de domaine Active Directory pour le domaine n’a pas pu être contacté » ou « Échec de la vérification de la réplication ».  
**Causes probables :**
- DNS incomplet.
- Ports bloqués.
- Problèmes de compatibilité.

**Étapes de diagnostic :**
1. Vérifier les logs :  
   - Event Viewer → Applications and Services Logs → Directory Service.  
   - Event Viewer → Windows Logs → System (rechercher ID 1925, 2087, 2088 pour DNS).  
   - Fichiers : `%systemroot%\debug\dcpromoui.log` et `dcpromo.log`.
2. Tester la réplication potentielle :  
   ```powershell
   repadmin /showrepl
   dcdiag /test:dns
   ```

**Résolution type :**
- Corriger DNS comme ci-dessus.
- Désactiver temporairement le pare-feu : `Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False` (puis réactiver après test).

### Problèmes post-promotion (après redémarrage)

**Symptôme 1 :** Impossible de se connecter au nouveau DC (ECO-BDX-EX02) après promotion – message « Nom d’utilisateur ou mot de passe incorrect ».  
**Causes probables :**
- Réplication SYSVOL/NETLOGON incomplète.
- Canal sécurisé rompu.

**Étapes de diagnostic :**
1. Vérifier les partages SYSVOL et NETLOGON :  
   ```cmd
   net share
   ```
   → Doivent apparaître SYSVOL et NETLOGON.
2. Vérifier le canal sécurisé :  
   ```cmd
   nltest /sc_verify:ecotech.local
   ```
3. Vérifier état réplication :  
   ```powershell
   repadmin /replsummary
   For /f %i IN ('dsquery server -o rdn') do @echo %i && @wmic /node:"%i" /namespace:\root\microsoftdfs path dfsrreplicatedfolderinfo WHERE replicatedfoldername='SYSVOL share' get state
   ```

**Résolution type :**
- Forcer réplication : `repadmin /syncall /AdeP`.
- Réinitialiser mot de passe machine : `netdom resetpwd /server:ECO-BDX-EX01 /userd:ecotech\Administrator /passwordd:*`.
- Purger tickets Kerberos système : `klist -li 0x3e7 purge`.
- Changer DNS temporairement vers DC principal, redémarrer Netlogon, attendre 15–30 min, puis repasser en loopback.
- Si SYSVOL absent : Vérifier DFSR (ou FRS sur anciens domaines), forcer authoritative/non-authoritative restore si nécessaire.
