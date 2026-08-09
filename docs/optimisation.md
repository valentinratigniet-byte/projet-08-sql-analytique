# Note d'optimisation

Mesures via `EXPLAIN (ANALYZE)` sur la base du projet 07 (120 k lignes de
commandes). Objectif : montrer **où un index change tout, et où il ne sert à rien**
— la distinction que fait un analyste qui comprend le planificateur.

## 1. Requête filtrée sélective → l'index fait tout

« Toutes les commandes d'un client donné » (`WHERE customer_id = 1234`).

| Plan | Temps |
|---|---|
| `Bitmap Index Scan` sur `idx_orders_customer_date` | **1,9 ms** |

Le planificateur cible directement les ~9 lignes du client au lieu de lire les
40 000 commandes. **Règle : un filtre sélectif sur une grosse table appelle un
index** (déjà créé dans le projet 07).

## 2. Agrégation sur toute la table → l'index ne sert à rien

« Chiffre d'affaires par mois » (`GROUP BY date_trunc('month', paid_at)`).

| Plan | Temps |
|---|---|
| `Seq Scan` sur `payment` puis `GroupAggregate` | **22 ms** |

Ici on doit **lire toutes les lignes** pour les additionner : un index ne réduit
rien (au contraire, il ralentirait les écritures pour zéro gain en lecture).
**Règle : ne pas indexer une colonne juste parce qu'elle est agrégée.** Le vrai
levier quand ce volume grossit :
- **table pré-agrégée / vue matérialisée** (`ca_mensuel` rafraîchie 1×/jour),
- **partitionnement par date** si la table atteint des dizaines de millions de lignes.

## 3. Requête analytique multi-jointures (cohortes)

La matrice de rétention (CTE + jointure `orders`×`orders`, agrégats `FILTER`) :
**~15 ms** sur 40 k commandes. Acceptable à cette échelle ; si elle devenait un
tableau de bord rafraîchi en continu, on la **matérialiserait** plutôt que de la
rejouer à chaque appel.

## À retenir
- Index = filtre **sélectif** sur grosse table. ✅
- Index ≠ solution aux **agrégations globales** (Seq Scan inévitable). ❌
- Passé un certain volume, on **pré-calcule** (vues matérialisées) au lieu d'optimiser la requête à la volée.
