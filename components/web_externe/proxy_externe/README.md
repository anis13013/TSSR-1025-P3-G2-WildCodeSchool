# Reverse Proxy – Point d’entrée sécurisé pour le site vitrine

## Rôle principal

Le serveur **ECO-BDX-EX09** (IP : 10.50.0.5 / DMZ) agit comme **unique point d’entrée** pour tout le trafic HTTP/HTTPS destiné au site vitrine de l’entreprise (ecotech-solutions.com).

Il remplit trois fonctions essentielles :

1. **Terminaison TLS** : déchiffre le trafic entrant sur le port 443  
2. **Redirection HTTP → HTTPS** : force l’utilisation du chiffrement  
3. **Relais inverse (reverse proxy)** : transmet les requêtes vers le vrai serveur web vitrine (10.50.0.6) sans l’exposer directement

Cette architecture protège le serveur de contenu final et respecte la segmentation réseau (DMZ isolée du LAN et du WAN).

## Position dans l’infrastructure

| Composant              | Adresse IP     | Zone / VLAN     | Rôle dans le flux vitrine                              |
|------------------------|----------------|-----------------|--------------------------------------------------------|
| Reverse Proxy          | 10.50.0.5      | DMZ (VLAN 500)  | Point d’entrée unique (WAN + LAN)                      |
| Serveur web vitrine    | 10.50.0.6      | DMZ (VLAN 500)  | Contient les pages – accessible uniquement depuis proxy|
| pfSense                | WAN publique   | WAN             | NAT 80/443 → 10.50.0.5                                 |
| Clients internes       | 10.x.x.x      | LAN         | Résolution DNS interne → 10.50.0.5                     |

## État de la Configuration

- Certificat : Auto-signé (SSL/TLS), généré via OpenSSL.
- Protocoles : Seuls TLS 1.2 et 1.3 sont autorisés. Tout ce qui est plus vieux (SSLv3, TLS 1.0/1.1) a été banni.
- Redirection : Forçage du HTTPS actif.
- Masquage d'identité (Hardening) : * ServerTokens Prod : Le serveur ne crie pas sa version sur tous les toits.
- ServerSignature Off : Les pages d'erreur sont "anonymes".
- DNS : Le Proxy répond au nom www.ecotech-solutions.com/ecotech-solutions.com grâce au Split-Horizon DNS configuré sur ton AD.
