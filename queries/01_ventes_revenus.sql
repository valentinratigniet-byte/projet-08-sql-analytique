-- =====================================================================
-- Thème 1 — Ventes & revenus (fondamentaux : agrégats, GROUP BY, jointures)
-- Base : projet 07 (e-commerce). On ne compte que le CA réellement encaissé
-- (table payment), pas les commandes annulées/en attente.
-- =====================================================================

-- Q1 — Quel est le chiffre d'affaires encaissé et le nombre de commandes payées, par mois ?
-- Technique : date_trunc + agrégats. La brique de tout reporting de revenus.
SELECT date_trunc('month', p.paid_at)::date AS mois,
       count(DISTINCT p.order_id)           AS commandes_payees,
       round(sum(p.amount), 2)              AS ca_encaisse
FROM payment p
GROUP BY 1
ORDER BY 1;

-- Q2 — Quels sont les 10 produits qui rapportent le plus de chiffre d'affaires ?
-- Technique : jointure order_item→product + agrégat, tri + LIMIT.
SELECT pr.sku, pr.name,
       sum(oi.quantity)                     AS unites_vendues,
       round(sum(oi.quantity * oi.unit_price), 2) AS ca
FROM order_item oi
JOIN product pr ON pr.id = oi.product_id
GROUP BY pr.id, pr.sku, pr.name
ORDER BY ca DESC
LIMIT 10;

-- Q3 — Comment le chiffre d'affaires se répartit-il par catégorie (et quelle part du total) ?
-- Technique : agrégat + fonction fenêtre pour le % du total (SUM() OVER ()).
SELECT c.name AS categorie,
       round(sum(oi.quantity * oi.unit_price), 2) AS ca,
       round(100.0 * sum(oi.quantity * oi.unit_price)
             / sum(sum(oi.quantity * oi.unit_price)) OVER (), 1) AS part_pct
FROM order_item oi
JOIN product  pr ON pr.id = oi.product_id
JOIN category c  ON c.id = pr.category_id
GROUP BY c.name
ORDER BY ca DESC;

-- Q4 — Quel est le panier moyen (AOV) par mois ?
-- Technique : CTE pour calculer le montant par commande, puis moyenne mensuelle.
WITH montant_commande AS (
    SELECT o.id, date_trunc('month', o.order_date)::date AS mois,
           sum(oi.quantity * oi.unit_price) AS montant
    FROM orders o
    JOIN order_item oi ON oi.order_id = o.id
    GROUP BY o.id, 2
)
SELECT mois,
       count(*)                 AS nb_commandes,
       round(avg(montant), 2)   AS panier_moyen
FROM montant_commande
GROUP BY mois
ORDER BY mois;
