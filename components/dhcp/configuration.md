# DHCP Configuration

----

---

## DHCP config (basic)

1. Dans le DHCP Manager, faites un clique droit, cliquez sur "New Scope".

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/01_dhcp_configuration.jpg)

2. Cliquez sur "Next".

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/02_dhcp_configuration.jpg)

3. Entrez un nom à votre scope, puis une description.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/03_dhcp_configuration.jpg)

4. Tapez le début et la fin de l'étendu de votre réseau, ensuite la longueur (CIDR).

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/04_dhcp_configuration.jpg)

5. Si vous voulez ajoutez des adresses ip d'exclusion, écrivez là dans l'onglet "Start IP address" & "End IP address" puis sur "Add" sinon cliquez sur "Next" directement.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/05_dhcp_configuration.jpg)

6. Tapez la durée du bail choisi pour votre Scope.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/06_dhcp_configuration.jpg)

7. Cochez "Yes, I want to configure these options now" pour poursuivre les configuration DHCP.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/07_dhcp_configuration.jpg)

8. Tapez l'ip de la route par défault, si il y en a une.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/08_dhcp_configuration.jpg)

9. Tapez le nom de domaine si vous en faites partie afin de l’attribuer à vos clients.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/09_dhcp_configuration.jpg)

10. Cliquez sur "Next".

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/10_dhcp_configuration.jpg)

11. Cochez la case "Yes, I want to activate this scope now" pour amorcer votre configuration.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/2dc664b6012611efe94f56269271f433d3a64ea1/components/dhcp/ressources/config/11_dhcp_configuration.jpg)

## DHCP config (Failover)


La suite de ce fichier expliquera le principe du mode DHCP Failover Load Balancing qui permet d’assurer la continuité de service et la haute disponibilité du DHCP en répartissant automatiquement les requêtes des clients entre deux serveurs. Dans cette infrastructure, ce mécanisme est mis en œuvre entre les serveurs 10.20.20.5 et 10.20.20.6, qui partagent la charge de distribution des adresses IP de manière équilibrée. Les deux serveurs synchronisent en permanence les informations de baux afin de garantir la cohérence des attributions, et un délai de grâce (grace period) est appliqué pour éviter les conflits d’adresses en cas de perte de communication temporaire entre eux. Ce mode permet ainsi de maintenir le service DHCP opérationnel même si l’un des serveurs devient momentanément indisponible, tout en assurant une gestion centralisée et fiable des adresses IP.

Configuration Failover DHCP

1. Dans **DHCP Manager**, faites un clic droit sur **"DHCP"** et sélectionnez **"Manage Authorized Servers..."**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/21_fovdhcp_configuration.jpg)

2. Cliquez sur **"Authorize..."**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/13_fovdhcp_configuration.jpg)

3. Tapez l'adresse IP de votre deuxième serveur DHCP.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/14_fovdhcp_configuration.jpg)

4. Sélectionnez le serveur secondaire.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/15_fovdhcp_configuration.jpg)

5. Ouvrez l'onglet de votre **premier serveur DHCP**, faites un clic droit sur **IPv4**, puis cliquez sur **"Configure Failover"**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/17_fovdhcp_configuration.jpg)

6. Laissez les options par défaut, cela va sélectionner tous vos scopes.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/01_fovdhcp_configuration.jpg)

7. Cliquez sur **"Add Server"**, puis **"Browse"** et sélectionnez votre deuxième serveur DHCP. Cliquez ensuite sur **"OK"**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/18_fovdhcp_configuration.jpg)

8. Cliquez sur **"Next"**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/19_fovdhcp_configuration.jpg)

9. **Onglet Configure Failover :** Donnez un nom au failover dans "Relationship Name". Laissez le "Maximum Client Lead Time" par défaut, c’est le temps maximum pendant lequel un serveur peut gérer un lease sans synchronisation. Choisissez le **Mode** : "Load Balance" pour que les deux serveurs soient actifs et se partagent les requêtes, ou "Hot Standby" pour qu’un serveur soit actif et l’autre en veille prête à prendre le relais. "State Switchover Interval" définit après combien de minutes un basculement automatique se fait si un serveur ne répond plus. Activez "Enable Message Authentication" pour sécuriser les échanges entre serveurs et entrez le "Shared Secret", mot de passe identique sur les deux serveurs pour chiffrer et authentifier les synchronisations.


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/20_fovdhcp_configuration.jpg)

10. Cliquez sur **"Finish"**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/02_fovdhcp_configuration.jpg)

11. Cliquez sur **"Close"**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/03_fovdhcp_configuration.jpg)


## Suite Configuration des 2 machines DHCP

1. Ouvrez **Server Manager** et cliquez sur **More**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/04_fovdhcp_configuration.jpg)

2. Cliquez sur **Complete DHCP Configuration**.


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/05_fovdhcp_configuration.jpg)

3. Cliquez sur **Next**.


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/06_fovdhcp_configuration.jpg)

4. Sélectionnez **Use the following user's credentials**, vérifiez que le nom d'utilisateur est celui de l'administrateur, puis cliquez sur **Commit**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/12_fovdhcp_configuration.png)

5. Cliquez sur **Close**.


![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/07_fovdhcp_configuration.jpg)

6. Retournez dans **DHCP Manager**, faites un clic droit sur **DHCP**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/08_fovdhcp_configuration.jpg)

7. Cliquez sur **Add Server...**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/09_fovdhcp_configuration.jpg)

8. Sélectionnez le deuxième serveur DHCP et cliquez sur **OK**.

![image](https://github.com/WildCodeSchool/TSSR-1025-P3-G2/blob/544b3db93d03ef2877291c14b42e131f3e55be39/components/dhcp/ressources/config/10_fovdhcp_configuration.jpg)

Vous avez configuré un **DHCP Failover** avec succès !











