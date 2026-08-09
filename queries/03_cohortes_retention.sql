-- =====================================================================
-- Thème 3 — Cohortes & rétention
-- La question à laquelle tout responsable e-commerce veut une réponse :
-- "mes clients reviennent-ils ?"
-- =====================================================================

-- Q9 — Matrice de rétention par cohorte d'acquisition.
-- Chaque client appartient à la cohorte de son 1er mois de commande ; on suit
-- combien reviennent M+0, M+1, M+2... Technique : MIN() OVER + différence de mois.
WITH premiere AS (   -- mois de 1re commande par client
    SELECT customer_id,
           min(date_trunc('month', order_date)) AS cohorte
    FROM orders GROUP BY customer_id
),
activite AS (        -- écart en mois entre chaque commande et la cohorte
    SELECT o.customer_id, p.cohorte,
           (date_part('year',  age(date_trunc('month', o.order_date), p.cohorte)) * 12
          + date_part('month', age(date_trunc('month', o.order_date), p.cohorte)))::int AS mois_ecoule
    FROM orders o JOIN premiere p ON p.customer_id = o.customer_id
)
SELECT cohorte::date AS cohorte,
       count(DISTINCT customer_id) FILTER (WHERE mois_ecoule = 0) AS m0,
       count(DISTINCT customer_id) FILTER (WHERE mois_ecoule = 1) AS m1,
       count(DISTINCT customer_id) FILTER (WHERE mois_ecoule = 2) AS m2,
       count(DISTINCT customer_id) FILTER (WHERE mois_ecoule = 3) AS m3
FROM activite
GROUP BY cohorte
ORDER BY cohorte
LIMIT 12;

-- Q10 — Chaque mois, combien de clients sont NOUVEAUX vs RÉCURRENTS ?
-- Technique : comparer le mois de la commande au 1er mois du client.
WITH premiere AS (
    SELECT customer_id, min(date_trunc('month', order_date)) AS cohorte
    FROM orders GROUP BY customer_id
)
SELECT date_trunc('month', o.order_date)::date AS mois,
       count(DISTINCT o.customer_id) FILTER (
           WHERE date_trunc('month', o.order_date) = p.cohorte) AS nouveaux,
       count(DISTINCT o.customer_id) FILTER (
           WHERE date_trunc('month', o.order_date) > p.cohorte) AS recurrents
FROM orders o JOIN premiere p ON p.customer_id = o.customer_id
GROUP BY 1
ORDER BY 1;
