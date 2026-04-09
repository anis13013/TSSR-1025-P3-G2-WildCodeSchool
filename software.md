# Logiciels prévisionnels pour la nouvelle infrastructure réseau

Inventaire des logiciels nécessaires

| Nom du logiciel                    | Service                           | Rôle                                                                          |
|------------------------------------|-----------------------------------|-------------------------------------------------------------------------------|
| Active Directory                   | Authentification / Annuaire       | Gestion centralisée des utilisateurs et ordinateurs                           |
| DNS                                | Résolution de noms                | Résolution noms internes et externes                                          |
| DHCP                               | Attribution IP                    | Distribution automatique des adresses IP                                      |
| Windows Server                     | Système d'exploitation serveurs   | Hébergement des services Windows                                              |
| FreePBX                            | Téléphonie IP                     | Gestion du standard VoIP et des communications                                |              
| pfSense                            | Firewall                          | Sécurité périmètre, filtrage, NAT, VPN                                        |
| Proxmox                            | Hyperviseur                       | Virtualisation des serveurs                                                   |
| Apache                             | Serveur Web                       | Hébergement sites web internes ou publics                                     |
| Microsoft Exchange                 | Messagerie                        | Gestion des emails internes et externes                                       |
| Windows Server (FSRM)              | Partage de fichiers               | Gestion des partages réseau, permissions NTFS et quotas.                      |
| WireGuard                          | VPN                               | Accès distant sécurisé                                                        |
| Microsoft Defender                 | Antivirus                         | Protéger contre les menaces                                                   |
| GLPI                               | Gestion de Parc / Ticket          | Inventaire du matériel et gestion des incidents (Helpdesk).                   |              
| MariaDB | Base de données | Stockage des données pour les applications web (GLPI, Snappy). |
| iRedMail  | Webmail | Interface : Accès web aux emails pour les utilisateurs. |

**Notes générales** :
- Windows pour le système AD / bureautique
- Authentification forte : MFA possible (surtout VPN, admin, email)







