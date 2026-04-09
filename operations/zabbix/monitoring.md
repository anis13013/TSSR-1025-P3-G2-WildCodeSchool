# Manuel d'Exploitation : Stratégie de Surveillance

Ce document décrit les éléments sous surveillance constante pour garantir la disponibilité de l'infrastructure.

# operations/MONITORING.md

# Liste des éléments surveillés dans Zabbix

Ce document recense les éléments supervisés dans l'infrastructure Zabbix 7.0. Il détaille les métriques clés, les seuils d'alerte et les triggers associés.

### 1. Hôtes principaux surveillés

| Hôte         | Type            | Modèle appliqué              | Objectif principal                  |
| ------------ | --------------- | ---------------------------- | ----------------------------------- |
| ECO-BDX-EX10 | Serveur Debian  | Linux by Zabbix agent        | Serveur Zabbix central              |
| ECO-BDX-EX11 | Proxy Zabbix    | Zabbix Proxy by Zabbix agent | Proxy pour sites distants           |
| ECO-BDX-DX03 | Routeur VyOS    | VyOS by Zabbix agent         | Routeur bordure                     |
| ECO-BDX-EX02 | Serveur Windows | Windows by Zabbix agent      | Serveur Active Directory secondaire |
|              |                 |                              |                                     |

### 2. Métriques et seuils critiques

| Métrique                       | Hôte concerné    | Seuil Warning | Seuil High | Trigger associé                    |
|--------------------------------|------------------|---------------|------------|------------------------------------|
| CPU Load (1min)                | Tous serveurs    | > 2.0         | > 4.0      | CPU load too high                  |
| CPU Usage (%)                  | Tous serveurs    | > 80%         | > 95%      | CPU utilization critical           |
| Mémoire libre (Mo)             | Tous serveurs    | < 500 Mo      | < 200 Mo   | Out of memory                      |
| Espace disque / (%)            | Serveurs Linux   | > 85%         | > 95%      | Disk space low                     |
| Trafic interface (eth0)        | VyOS + Proxy     | > 80%         | > 95%      | Interface saturation               |

**Dernière mise à jour** : 16/02/2026


