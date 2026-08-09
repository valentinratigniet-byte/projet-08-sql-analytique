# Projet 08 — Bibliothèque de requêtes SQL analytiques

> **Quelle requête pour quelle question métier ?** 16 requêtes analytiques
> commentées, chacune répondant à une vraie question business, **exécutées et
> vérifiées** sur la base e-commerce du [Projet 07](https://github.com/valentinratigniet-byte/projet-07-base-ecommerce).
>
> Objectif : prouver la maîtrise du SQL avancé (fonctions fenêtres, CTE
> récursives, cohortes, RFM) au-delà du simple `SELECT ... WHERE`.

## 🔎 Index « question → requête »

| # | Question métier | Technique SQL | Fichier |
|---|---|---|---|
| Q1 | CA encaissé et commandes payées par mois ? | `date_trunc` + agrégats | [01](queries/01_ventes_revenus.sql) |
| Q2 | Top 10 produits par chiffre d'affaires ? | jointure + `ORDER BY … LIMIT` | [01](queries/01_ventes_revenus.sql) |
| Q3 | Répartition du CA par catégorie (part %) ? | `SUM() OVER ()` | [01](queries/01_ventes_revenus.sql) |
| Q4 | Panier moyen (AOV) par mois ? | CTE + `AVG` | [01](queries/01_ventes_revenus.sql) |
| Q5 | CA cumulé mois après mois (running total) ? | `SUM() OVER (ORDER BY)` | [02](queries/02_fonctions_fenetres.sql) |
| Q6 | Top 3 produits **par catégorie** ? | `ROW_NUMBER() OVER (PARTITION BY)` | [02](queries/02_fonctions_fenetres.sql) |
| Q7 | Croissance du CA d'un mois sur l'autre (MoM %) ? | `LAG()` | [02](queries/02_fonctions_fenetres.sql) |
| Q8 | Moyenne glissante 3 mois du CA ? | `AVG() OVER (ROWS BETWEEN …)` | [02](queries/02_fonctions_fenetres.sql) |
| Q9 | Matrice de rétention par cohorte d'acquisition ? | `MIN`, `age()`, `FILTER` | [03](queries/03_cohortes_retention.sql) |
| Q10 | Clients nouveaux vs récurrents par mois ? | agrégat conditionnel `FILTER` | [03](queries/03_cohortes_retention.sql) |
| Q11 | Segmentation RFM (Récence/Fréquence/Montant) ? | `NTILE(5)` | [04](queries/04_clients_rfm.sql) |
| Q12 | Top 15 clients par valeur vie (LTV) ? | agrégat + tri | [04](queries/04_clients_rfm.sql) |
| Q13 | Part de clients « one-shot » (1 seule commande) ? | CTE + `FILTER` | [04](queries/04_clients_rfm.sql) |
| Q14 | Arborescence des catégories (parent → enfant) ? | **CTE récursive** | [05](queries/05_sql_avance.sql) |
| Q15 | Produits actifs jamais commandés (stock dormant) ? | sous-requête corrélée `NOT EXISTS` | [05](queries/05_sql_avance.sql) |
| Q16 | Part de chaque ligne dans le total d'une commande ? | `SUM() OVER (PARTITION BY)` | [05](queries/05_sql_avance.sql) |

## 📊 Quelques résultats (vérifiés sur données réelles)

**CA par catégorie** (Q3) — top 3 sur 10 :

| Catégorie | CA | Part |
|---|---:|---:|
| Jouets | 8 736 526 € | 12,0 % |
| Alimentation | 8 209 461 € | 11,2 % |
| Mode | 7 785 946 € | 10,7 % |

**Croissance MoM** (Q7) — premiers mois : +43,8 %, +8,4 %, −2,1 %, +2,9 %…
(variations réalistes, pas un CA plat).

**Clients one-shot** (Q13) : 0,3 % — la base seed génère des clients très
récurrents ; sur données réelles, ce KPI est un signal d'alerte fidélisation clé.

## ⚡ Optimisation

Note dédiée : **[docs/optimisation.md](docs/optimisation.md)** — où un index
divise le temps par 10 (filtre sélectif) et où il ne sert à rien (agrégation
globale → `Seq Scan` inévitable, on pré-calcule à la place).

## 🚀 Rejouer les requêtes

Prérequis : la base du Projet 07 lancée (Docker, port 5433).

```bash
# depuis le repo du projet 07 : docker compose up -d && python seed/seed.py
docker exec -i p07_ecommerce_db psql -U portfolio -d ecommerce < queries/01_ventes_revenus.sql
# … idem pour 02 à 05
```

Ou connecte un client (DBeaver) sur `localhost:5433`, base `ecommerce`,
`portfolio` / `portfolio`, et ouvre les fichiers `queries/*.sql`.

## 🗂️ Structure

```
projet-08-sql-analytique/
├── README.md                       ← index question → requête
├── queries/
│   ├── 01_ventes_revenus.sql       ← Q1–Q4  fondamentaux
│   ├── 02_fonctions_fenetres.sql   ← Q5–Q8  window functions
│   ├── 03_cohortes_retention.sql   ← Q9–Q10 cohortes
│   ├── 04_clients_rfm.sql          ← Q11–Q13 RFM / LTV
│   └── 05_sql_avance.sql           ← Q14–Q16 CTE récursive, NOT EXISTS
└── docs/
    └── optimisation.md
```

---

*Projet 08 du [Portfolio Data](../). S'appuie sur le Projet 07. Prochaine brique :
Projet 09 — dashboard exécutif Power BI sur cette même base.*
