## Maintenance & Reprise — Contrôleurs de Domaine EcoTech

Ce document couvre la vérification de la réplication entre les DCet les procédures de reprise après panne.

## Table des matières :

- [1 : Vérification de la Réplication](#1--vérification-de-la-réplication)
  - [1.1. Résumé de réplication (replsummary)](#11-résumé-de-réplication-replsummary)
  - [1.2. Détail des voisins entrants (showrepl)](#12-détail-des-voisins-entrants-showrepl)
- [2. Procédure de Reprise après Panne](#2-procédure-de-reprise-après-panne)
  - [2.1. Panne du DC Secondaire (EX02)](#21-panne-du-dc-secondaire-ex02)
  - [2.2. Panne du DC Principal (EX01)](#22-panne-du-dc-principal-ex01)
  - [2.3. Perte totale — Restauration depuis sauvegarde](#23-perte-totale--restauration-depuis-sauvegarde)

## 1 : Vérification de la Réplication

La réplication entre EX01 et EX02 garantit que toute modification (utilisateur, GPO, mot de passe) est bien synchronisée sur les deux DC. Ces commandes sont à lancer depuis EX01 ou EX02 indifféremment.

### 1.1. Résumé de réplication (replsummary)

`powershellrepadmin /replsummary`

- Un résultat fails/total = 0/5 et error = 0 sur les deux DC confirme que la réplication fonctionne correctement.

### 1.2. Détail des voisins entrants (showrepl)

`powershellrepadmin /showrepl`

- Cette commande affiche le détail des partitions répliquées. La mention Last attempt [...] was successful sur chacune des partitions ci-dessous confirme la synchronisation complète :

``` Powershell
DC=ecotech,DC=local
CN=Configuration,DC=ecotech,DC=local
CN=Schema,CN=Configuration,DC=ecotech,DC=local
DC=DomainDnsZones,DC=ecotech,DC=local
DC=ForestDnsZones,DC=ecotech,DC=local
```


## 2. Procédure de Reprise après Panne

### 2.1. Panne du DC Secondaire (EX02)

Cas le plus courant et le moins critique — EX01 continue de fonctionner normalement, les utilisateurs ne voient rien.

1. Vérifier qu'EX01 répond correctement :
`powershelldcdiag /test:replications`

2. Identifier la cause de la panne (matériel, OS, réseau)

3. Les commandes les plus importantes pour un diagnostic rapide :

- `dcdiag /v` — diagnostic complet
- `repadmin /replsummary` — état de la réplication
- `Get-Service NTDS, DNS, Netlogon` — services actifs
- `Test-NetConnection -ComputerName <autre_DC> -Port 389` — connectivité
 
*Quelques commandes pour diagnostiquer plus précisément le DC :*

- Diagnostic général du DC

 ``` Powershell
# Test complet du contrôleur de domaine (le plus important !)
dcdiag /v

# Test spécifique de la réplication uniquement
dcdiag /test:replications

# Test de la connectivité réseau entre DC
dcdiag /test:connectivity
```

- Etat de la réplication

``` Powershell
# Résumé de réplication (vu précédemment)
repadmin /replsummary

# Forcer la réplication immédiate depuis l'autre DC
repadmin /syncall /AdeP

# Voir les échecs de réplication
repadmin /showrepl /errorsonly

# Afficher la dernière réplication réussie
repadmin /showrepl
```

- Vérification DNS

``` Powershell
# Test de résolution du domaine
nslookup ecotech.local

# Test des enregistrements SRV (critiques pour AD)
nslookup -type=srv _ldap._tcp.dc._msdcs.ecotech.local

# Enregistrer manuellement les SRV si manquants
ipconfig /registerdns
```

- État des Services AD

``` Powershell
# Vérifier que les services AD tournent
Get-Service NTDS, DNS, KDC, Netlogon | Select Name, Status

# Redémarrer le service AD si besoin
Restart-Service NTDS -Force
```

- Connectivité Réseau

``` Powershell
# Ping de l'autre DC
ping 10.20.20.6

# Test des ports AD (389 LDAP, 636 LDAPS, 88 Kerberos)
Test-NetConnection -ComputerName 10.20.20.6 -Port 389
Test-NetConnection -ComputerName ECO-BDX-EX02 -Port 88

# Tracer la route réseau
tracert 10.20.20.6
```

- Vérification des Rôles FSMO

``` Powershell
# Voir qui porte les rôles FSMO
netdom query fsmo

# Alternative via PowerShell
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
```

- Logs Windows 

``` Powershell
# 50 derniers événements d'erreur AD
Get-EventLog -LogName "Directory Service" -EntryType Error -Newest 50

# Événements de réplication AD
Get-EventLog -LogName "Directory Service" | Where-Object {$_.EventID -eq 1864 -or $_.EventID -eq 2042}
```

- Vérifier la Santé de la Base NTDS

``` Powershell
# Vérifier l'intégrité de la base AD
ntdsutil
> activate instance ntds
> files
> info
> quit
> quit
```

4. Si EX02 est irrécupérable, le retirer proprement depuis EX01 :

``` Powershell
powershellntdsutil
> metadata cleanup
> remove selected server ECO-BDX-EX02
```

5. Redéployer EX02 en suivant le document installation.md

6. Vérifier la réplication une fois EX02 de retour :

``` Powershell
powershellrepadmin /replsummary
```

### 2.2. Panne du DC Principal (EX01)

Cas plus critique — EX02 prend le relais automatiquement pour l'authentification, mais les rôles FSMO doivent être transférés manuellement.

1. Vérifier qu'EX02 répond et authentifie correctement

2. Transférer les rôles FSMO vers EX02 :

``` Powershell
Move-ADDirectoryServerOperationMasterRole -Identity "ECO-BDX-EX02" -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster
```

3. Vérifier que les rôles sont bien portés par EX02 :

``` Powershell
powershellnetdom query fsmo
```

4. Mettre à jour les entrées DNS clients si nécessaire pour pointer vers 10.20.20.6
   
5. Réparer ou redéployer EX01 via installation.md, puis retransférer les rôles FSMO vers EX01 si souhaité


### 2.3. Perte totale — Restauration depuis sauvegarde

Cas extrême : les deux DC sont perdus simultanément. La restauration repose sur la dernière sauvegarde disponible.

1. Déployer un nouveau serveur Windows Server et le configurer (IP 10.20.20.5, nom ECO-BDX-EX01) en suivant installation.md

2. Installer le rôle AD DS sans promouvoir :

``` Powershell
powershellInstall-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
```

3. Identifier la version de sauvegarde à restaurer :

``` Powershell
powershellwbadmin get versions
```

4. Lancer la restauration du System State :

``` Powershell
powershellwbadmin start systemstaterecovery -version:<VERSION> -quiet
```

5. Le serveur redémarre automatiquement en tant que DC restauré avec toute la base AD

6. Vérifier l'intégrité du domaine :

``` Powershell
dcdiag
repadmin /replsummary
```

7. Redéployer EX02 en suivant installation.md une fois EX01 opérationnel
