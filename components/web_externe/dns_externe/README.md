# DNS Interne – Split-Horizon pour le site vitrine ecotech-solutions.com

## Rôle de cette brique

Cette configuration DNS interne permet aux utilisateurs (LAN métiers) et (WAN) de résoudre correctement le nom de domaine public de l’entreprise :

**ecotech-solutions.com**  
**www.ecotech-solutions.com**

La résolution renvoie systématiquement l’adresse IP du **Reverse Proxy** situé en DMZ : **10.50.0.5**

Objectif principal :  
forcer tout le trafic HTTP/HTTPS des postes internes à transiter par le Reverse Proxy, et non directement vers le serveur web vitrine.

## Pourquoi un serveur vitrine et pourquoi en DMZ ?

Le serveur web (10.50.0.6) est un **serveur vitrine** :  
c’est le site internet officiel de l’entreprise, destiné à être consulté par le public (visiteurs externes, partenaires, candidats…).

Caractéristiques d’un serveur vitrine :
- contenu public (présentation, services, actualités…)
- doit être accessible depuis Internet (WAN)
- ne doit **jamais** être directement exposé à Internet

Pour répondre à ces deux exigences, le serveur vitrine est placé en **DMZ** (VLAN 500) et protégé par un **Reverse Proxy** :

| Élément                  | Adresse IP     | Zone          | Rôle dans l’exposition publique                          |
|--------------------------|----------------|---------------|----------------------------------------------------------|
| Reverse Proxy            | 10.50.0.5      | DMZ | Seul point d’entrée visible depuis le WAN                |
| Serveur web vitrine      | 10.50.0.6      | DMZ | Contient les pages du site – jamais accessible directement |
| pfSense                  | WAN publique   | WAN           | NAT / Port Forwarding vers le Reverse Proxy               |

La DMZ est une zone intermédiaire entre le WAN et le LAN.  
Elle permet d’exposer des services publics tout en isolant fortement le réseau interne.

## Flux de résolution et d’accès

### Depuis le LAN (utilisateurs internes)

1. Poste client (ex. 10.60.x.x) → navigateur → https://www.ecotech-solutions.com  
2. Interrogation du DNS interne (serveur AD 10.20.20.5)  
3. Réponse DNS : A record = 10.50.0.5  
4. Connexion HTTPS vers le Reverse Proxy (10.50.0.5)  
5. Reverse Proxy relaie la requête vers le serveur vitrine (10.50.0.6)

→ Trafic 100 % interne (LAN → DMZ)

### Depuis le WAN (utilisateurs externes)

1. Utilisateur externe → navigateur → https://www.ecotech-solutions.com  
2. Résolution DNS publique (registrar ou simulation) → IP publique du pfSense  
3. pfSense effectue NAT / Port Forwarding TCP 80 & 443 → 10.50.0.5  
4. Reverse Proxy termine le TLS et relaie vers le serveur vitrine (10.50.0.6)

→ Le WAN ne voit jamais directement le serveur vitrine.

## Enregistrements DNS configurés (zone interne)

| Enregistrement                | Type | Valeur         | Commentaire                                      |
|-------------------------------|------|----------------|--------------------------------------------------|
| ecotech-solutions.com         | A    | 10.50.0.5      | Zone apex → Reverse Proxy                        |
| www.ecotech-solutions.com     | CNAME    | 10.50.0.5      | Alias www → Reverse Proxy                        |

## Sécurité minimale appliquée

- Reverse Proxy termine le TLS (certificat installé dessus)  
- Masquage de la bannière serveur (ServerTokens Prod)  
- Serveur vitrine non accessible directement depuis le WAN ni depuis le LAN  
- Règles de pare-feu pfSense limitent les flux autorisés vers la DMZ

## Validation effectuée

- nslookup www.ecotech-solutions.com depuis un poste interne → réponse 10.50.0.5  
- Navigation HTTPS depuis un poste LAN → page servie via Reverse Proxy  

