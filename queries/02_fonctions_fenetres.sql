-- =====================================================================
-- Thème 2 — Fonctions fenêtres (window functions)
-- Le cœur du SQL analytique : calculer sur un groupe SANS écraser les lignes.
-- =====================================================================

-- Q5 — Quel est le chiffre d'affaires cumulé (running total) mois après mois ?
-- Technique : SUM() OVER (ORDER BY ...) — cumul glissant.
WITH ca_mensuel AS (
    SELECT date_trunc('month', paid_at)::date AS mois, sum(amount) AS ca
    FROM payment GROUP BY 1
)
SELECT mois,
       round(ca, 2)                                          AS ca_mois,
       round(sum(ca) OVER (ORDER BY mois), 2)                AS ca_cumule
FROM ca_mensuel
ORDER BY mois;

-- Q6 — Dans chaque catégorie, quels sont les 3 produits les plus vendus ?
-- Technique : ROW_NUMBER() OVER (PARTITION BY ...) = top-N par groupe.
WITH ventes AS (
    SELECT c.name AS categorie, pr.name AS produit,
           sum(oi.quantity * oi.unit_price) AS ca,
           row_number() OVER (PARTITION BY c.name
                              ORDER BY sum(oi.quantity * oi.unit_price) DESC) AS rang
    FROM order_item oi
    JOIN product  pr ON pr.id = oi.product_id
    JOIN category c  ON c.id = pr.category_id
    GROUP BY c.name, pr.name
)
SELECT categorie, rang, produit, round(ca, 2) AS ca
FROM ventes
WHERE rang <= 3
ORDER BY categorie, rang;

-- Q7 — Quelle est la croissance du CA d'un mois sur l'autre (MoM %) ?
-- Technique : LAG() pour comparer à la ligne précédente.
WITH ca_mensuel AS (
    SELECT date_trunc('month', paid_at)::date AS mois, sum(amount) AS ca
    FROM payment GROUP BY 1
)
SELECT mois,
       round(ca, 2)                                        AS ca,
       round(lag(ca) OVER (ORDER BY mois), 2)              AS ca_mois_precedent,
       round(100.0 * (ca - lag(ca) OVER (ORDER BY mois))
             / nullif(lag(ca) OVER (ORDER BY mois), 0), 1) AS croissance_pct
FROM ca_mensuel
ORDER BY mois;

-- Q8 — Quelle est la moyenne glissante du CA sur 3 mois (lissage de tendance) ?
-- Technique : AVG() OVER (... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
WITH ca_mensuel AS (
    SELECT date_trunc('month', paid_at)::date AS mois, sum(amount) AS ca
    FROM payment GROUP BY 1
)
SELECT mois, round(ca, 2) AS ca,
       round(avg(ca) OVER (ORDER BY mois
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moyenne_3m
FROM ca_mensuel
ORDER BY mois;
