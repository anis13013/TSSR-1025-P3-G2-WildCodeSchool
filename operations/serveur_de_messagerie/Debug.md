# Dépannage iRedMail (Problèmes les plus fréquents)

Ce guide couvre les **bugs et erreurs** les plus courants **pendant l'installation** et **après** sur Debian.


## 1. Commandes de diagnostic de base (exécutez toujours en premier)

```bash
# Services critiques
systemctl status --no-pager postfix dovecot amavis-new nginx mariadb fail2ban

# Ports en écoute ?
ss -ltnp | grep -E ':25|:465|:587|:993|:995|:80|:443'

# Logs mail en temps réel (indispensable !)
tail -f /var/log/mail.log

# Logs installation (si échec pendant setup)
cat /root/iRedMail-*/*.log   # ou ls -l /root/iRedMail-*
```
