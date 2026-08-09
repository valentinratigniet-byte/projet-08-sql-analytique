-- =====================================================================
-- Thème 4 — Analyse client (RFM, LTV, fidélité)
-- Segmenter les clients pour cibler les actions marketing.
-- =====================================================================

-- Q11 — Segmentation RFM : noter chaque client sur Récence, Fréquence, Montant.
-- Technique : NTILE(5) découpe la population en quintiles (1 = faible, 5 = fort).
WITH base AS (
    SELECT o.customer_id,
           max(o.order_date)                    AS derniere_commande,
           count(DISTINCT o.id)                 AS frequence,
           sum(oi.quantity * oi.unit_price)     AS montant
    FROM orders o
    JOIN order_item oi ON oi.order_id = o.id
    GROUP BY o.customer_id
)
SELECT customer_id,
       (current_date - derniere_commande::date)                   AS jours_depuis_achat,
       frequence, round(montant, 2)                               AS montant,
       ntile(5) OVER (ORDER BY derniere_commande)                 AS r,  -- récent = score haut
       ntile(5) OVER (ORDER BY frequence)                         AS f,
       ntile(5) OVER (ORDER BY montant)                           AS m
FROM base
ORDER BY montant DESC
LIMIT 20;

-- Q12 — Top 15 clients par valeur vie (LTV = total dépensé).
-- Technique : agrégat + jointure, tri décroissant.
SELECT c.id, c.email, c.country,
       count(DISTINCT o.id)                        AS nb_commandes,
       round(sum(oi.quantity * oi.unit_price), 2)  AS ltv
FROM customer c
JOIN orders     o  ON o.customer_id = c.id
JOIN order_item oi ON oi.order_id  = o.id
GROUP BY c.id, c.email, c.country
ORDER BY ltv DESC
LIMIT 15;

-- Q13 — Quelle part des clients n'a commandé qu'UNE seule fois (one-shot) ?
-- Technique : CTE de comptage + agrégat conditionnel FILTER.
WITH par_client AS (
    SELECT customer_id, count(*) AS nb FROM orders GROUP BY customer_id
)
SELECT count(*)                                            AS clients_actifs,
       count(*) FILTER (WHERE nb = 1)                      AS one_shot,
       round(100.0 * count(*) FILTER (WHERE nb = 1) / count(*), 1) AS pct_one_shot
FROM par_client;
