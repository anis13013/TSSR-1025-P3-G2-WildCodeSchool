<h2 id="haut-de-page">Table des matières</h1>

- [1. Vue d'ensemble](#1-vue-densemble)
- [2. Planification par sprint](#2-planification-par-sprint)
  - [2.1. Sprint 01 (Semaine 1) - Analyse et documentation](#21-sprint-01-semaine-1---analyse-et-documentation)
  - [2.2. Sprint 02 (Semaines 2-3) - Infrastructure de base](#22-sprint-02-semaines-2-3---infrastructure-de-base)
  - [2.3. Sprint 03 (Semaines 4-5) - Services cœur](#23-sprint-03-semaines-4-5---services-cœur)
  - [2.4. Sprint 04 (Semaines 6-7) - Services métier](#24-sprint-04-semaines-6-7---services-métier)
  - [2.5. Sprint 05 (Semaines 8-9) - Sécurité et optimisation](#25-sprint-05-semaines-8-9---sécurité-et-optimisation)
  - [2.6. Sprint 06 (Semaine 10) - Finalisation](#26-sprint-06-semaine-10---finalisation)
- [3. Synthèse Gantt](#3-synthèse-gantt)
- [4. Estimation totale des heures](#4-estimation-totale-des-heures)


## 1. Vue d'ensemble
<span id="1-vue-densemble"></span>

| Information | Détail |
|-------------|--------|
| **Entreprise** | ÉcoTech Solutions |
| **Durée totale** | 10 semaines (50 jours ouvrables) |
| **Nombre de sprints** | 6 sprints |
| **Heures estimées totales** | 740 heures |
| **Équipe** | 4 personnes |

**Calendrier global :**
- **Sprint 01** : Semaine 1 (5 jours)
- **Sprint 02** : Semaines 2-3 (10 jours)
- **Sprint 03** : Semaines 4-5 (10 jours)
- **Sprint 04** : Semaines 6-7 (10 jours)
- **Sprint 05** : Semaines 8-9 (10 jours)
- **Sprint 06** : Semaine 10 (5 jours)

---

## 2. Planification par sprint
<span id="2-planification-par-sprint"></span>

### 2.1. Sprint 01 (Semaine 1) - Analyse et documentation
<span id="21-sprint-01-semaine-1---analyse-et-documentation"></span>

**Objectifs principaux :**
1. Analyse du sujet d'entreprise
2. Création de l'arborescence Github
3. Documentation complète initiale

**Total Sprint 01 :** 70 heures

**Livrables attendus :**
- Documentation DAT complète
- Documentation HLD initiale
- Structure Github complète
- Fichier de suivi sprint-01/README.md

### 2.2. Sprint 02 (Semaines 2-3) - Infrastructure de base
<span id="22-sprint-02-semaines-2-3---infrastructure-de-base"></span>

**Objectifs principaux :**
1. Environnement de virtualisation opérationnel
2. Serveurs de base installés
3. Réseau de base configuré

**Total Sprint 02 :** 70 heures

**Livrables attendus :**
- Environnement virtuel opérationnel
- Serveurs Windows et Linux installés
- VLANs de base configurés
- Documentation LLD à jour

### 2.3. Sprint 03 (Semaines 4-5) - Services cœur
<span id="23-sprint-03-semaines-4-5---services-cœur"></span>

**Objectifs principaux :**
1. Active Directory Domain Services
2. DNS et DHCP opérationnels
3. Authentification centralisée

**Total Sprint 03 :** 70 heures

**Livrables attendus :**
- AD DS opérationnel
- DNS/DHCP fonctionnels
- Utilisateurs et groupes créés
- Tests d'authentification validés

### 2.4. Sprint 04 (Semaines 6-7) - Services métier
<span id="24-sprint-04-semaines-6-7---services-métier"></span>

**Objectifs principaux :**
1. Serveur de fichiers avec quotas
2. Supervision infrastructure
3. Services d'impression

**Total Sprint 04 :** 70 heures

**Livrables attendus :**
- Serveur de fichiers opérationnel
- Supervision active
- Services d'impression configurés
- Documentation DEX initiale

### 2.5. Sprint 05 (Semaines 8-9) - Sécurité et optimisation
<span id="25-sprint-05-semaines-8-9---sécurité-et-optimisation"></span>

**Objectifs principaux :**
1. DMZ et services exposés
2. Sécurisation avancée
3. VPN d'accès distant

**Total Sprint 05 :** 70 heures

**Livrables attendus :**
- DMZ opérationnelle
- VPN fonctionnel
- Systèmes durcis
- Documentation sécurité à jour

### 2.6. Sprint 06 (Semaine 10) - Finalisation
<span id="26-sprint-06-semaine-10---finalisation"></span>

**Objectifs principaux :**
1. Tests complets et validation
2. Documentation finale
3. Présentation projet

**Total Sprint 06 :** 60 heures

**Livrables attendus :**
- Tests complets validés
- Documentation finale
- Présentation prête
- Dépôt Github nettoyé

## 3. Synthèse Gantt
<span id="3-synthèse-gantt"></span>

**Tableau de synthèse :** LIEN

## 4. Estimation totale des heures
<span id="4-estimation-totale-des-heures"></span>

**Répartition par type de tâche :**

| Catégorie | Heures | Pourcentage |
|-----------|--------|-------------|
| Documentation | 180h | 24.3% |
| Installation/config | 240h | 32.4% |
| Tests/validation | 160h | 21.6% |
| Sécurité | 90h | 12.2% |
| Gestion projet | 70h | 9.5% |
| **Total** | **740h** | **100%** |

**Répartition par membre :**
- Chaque membre : ~185 heures sur 10 semaines
- Charge hebdomadaire moyenne : ~18.5 heures/membre
- Charge journalière moyenne : ~3.7 heures/membre

**Points d'attention :**
- Sprints 2-5 ont la même charge (70h)
- Sprint 6 légèrement plus léger (60h) pour la finalisation
- Documentation représente près d'1/4 du temps total
- Tests et validation sont critiques pour la qualité

## 5. Dépendances critiques
<span id="5-dépendances-critiques"></span>

1. **Sprint 2** → **Sprint 1** : Environnement virtuel nécessite documentation validée
2. **Sprint 3** → **Sprint 2** : AD nécessite serveurs Windows installés
3. **Sprint 4** → **Sprint 3** : Services fichiers nécessitent AD fonctionnel
4. **Sprint 5** → **Sprint 4** : Sécurité nécessite services métier stables
5. **Sprint 6** → **Sprint 5** : Tests finaux nécessitent sécurité implémentée

## 6. Risques identifiés
<span id="6-risques-identifiés"></span>

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Retard documentation | Moyenne | Élevé | Validation quotidienne par PO |
| Problèmes compatibilité | Faible | Moyen | Tests réguliers, rollback possible |
| Charge travail inégale | Moyenne | Moyen | Rotation rôles, suivi SM |
| Problèmes réseau | Faible | Élevé | Documentation détaillée, sauvegardes |

*Ce planning est un document évolutif qui sera mis à jour en fonction de l'avancement réel.*  
*Les estimations sont indicatives et pourront être ajustées.*  

<p align="right">
  <a href="#haut-de-page">⬆️ Retour au début de la page ⬆️</a>
</p>
