# FreePBX - Surveillance et Monitoring

**Version du système :** FreePBX 16.0.33 (Sangoma Linux 7)  
**Date de réalisation :** Février 2026  

Bonjour,

Ce document vous explique comment surveiller efficacement votre serveur FreePBX au quotidien. Une bonne surveillance permet de détecter rapidement les anomalies, d’anticiper les incidents et de garantir une haute disponibilité de votre système de téléphonie.

---

### 1. Accès au Dashboard principal

L’outil de surveillance le plus important est le **Dashboard** de FreePBX.

Connectez-vous à l’interface d’administration :  
**`http://10.60.70.5/admin`**

Le Dashboard vous offre une vue d’ensemble en temps réel comprenant :
- Nombre d’utilisateurs en ligne et hors ligne
- Statut des trunks SIP
- Utilisation des ressources système (CPU, Mémoire, Disque)
- Trafic réseau en direct sur l’interface `eth0`
- Alertes critiques (weak secrets, bad destinations, etc.)

Nous vous recommandons de consulter ce Dashboard tous les matins.

---

### 2. Surveillance via l’interface graphique

#### Extensions et postes
- Allez dans **Applications → Extensions**
- Vérifiez la colonne **CW**, **DND**, **CF** et le statut d’enregistrement de chaque poste.

#### Trunks
- Allez dans **Connectivity → Trunks**
- Assurez-vous que vos trunks externes sont bien en statut "Online".

#### Rapports et historiques
- **Reports → CDR Reports** : Consultez l’historique des appels (durée, destination, statut).
- **Reports → Asterisk Logfiles** : Accédez aux logs détaillés d’Asterisk.

#### Firewall
- **Connectivity → Firewall → Status** : Vérifiez l’état du Sangoma Smart Firewall et les tentatives de connexion bloquées.

---

### 3. Monitoring via la ligne de commande (SSH)

Connectez-vous en SSH sur le serveur (`ssh root@10.60.70.5`).

**Commandes essentielles :**

# Statut général du système FreePBX
fwconsole status

# Liste des endpoints PJSIP et leur statut d'enregistrement
asterisk -rx "pjsip show endpoints"

# Liste des enregistrements en cours
asterisk -rx "pjsip show registrations"

# Afficher les canaux (appels) en cours
asterisk -rx "core show channels"

# Voir les logs Asterisk en temps réel
tail -f /var/log/asterisk/full

# Ressources système
htop
free -h
df -h

4. Configuration des alertes par email
Pour être notifié automatiquement des problèmes :

Allez dans Admin → Module Admin
Installez/Activez le module Email si nécessaire
Allez dans Admin → Email
Configurez votre serveur SMTP (Gmail, OVH, etc.)
Activez les notifications pour les erreurs critiques


5. Bonnes pratiques de monitoring

Consultez le Dashboard quotidiennement
Corrigez immédiatement les avertissements « weak secrets »
Surveillez régulièrement l’espace disque (les enregistrements et logs peuvent grossir rapidement)
Vérifiez une fois par semaine les logs du firewall pour détecter d’éventuelles attaques
Créez une sauvegarde avant toute modification importante


Une surveillance régulière et proactive vous permettra de maintenir votre système FreePBX dans des conditions optimales de performance et de sécurité.
Si vous avez besoin d’outils de monitoring avancés (Zabbix, Prometheus, Grafana), n’hésitez pas à demander une documentation complémentaire.
