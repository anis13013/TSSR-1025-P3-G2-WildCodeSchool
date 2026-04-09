# Matériels prévisionnels pour la nouvelle infrastructure réseau 

Inventaire des équipements physiques nécessaires

| Nom équipement          | Type                               | Rôle principal                                  |
|-------------------------|------------------------------------|-------------------------------------------------|
| SW_COEUR                | Switch L3                          | Routage inter-VLAN, Cœur de réseau.              |
| SW_ACCES                | Switch L2                          | Distribution d'accès aux bureaux (PC, Imprimantes). |
| FW                      | Firewall                           | Périmètre + VPN + NAT DMZ                       |
| SRV_AD                  | Serveur                            | Contrôleurs de domaine Active Directory         |
| SRV_VoIP                | Serveur                            | Serveur téléphonique VoIP                       |
| SRV_DHCP                | Serveur                            | Attribue automatiquement une adresse IP         |
| SRV_DNS                 | Serveur                            | Résolutions de noms                             |
| SRV_VIRTUAL_01             | Serveur                            | Hyperviseur (Proxmox)                           |
| SRV_VIRTUAL_02          | Serveur Physique                     | Hyperviseur (Proxmox) - Nœud 2 (Redondance).    | 
| NAS_STORAGE             | NAS                                | Stockage fichiers, sauvegardes                  |
| SRV_WEB                 | Serveur                            | Site web                                        |
| SRV_VPN                 | Serveur                            | Accès distant sécurisé                          |
| BORNE_WIFI              | Point d'accès WIFI                 | Couverture WIFI sur site                        |
| PC-PORTABLES            | Ordinateur Client                  | Postes de travail des 251 collaborateurs (Hôte de Thunderbird).|
| POSTES-IP               | Téléphone Fixe                     | Téléphones physiques pour les bureaux.          |


**Notes générales** :
- Redondance physique et logique sur les équipements critiques
- Alimentation double sur tous les équipements serveurs




