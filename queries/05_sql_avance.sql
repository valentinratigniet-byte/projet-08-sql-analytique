-- =====================================================================
-- Thème 5 — SQL avancé (CTE récursive, sous-requête corrélée)
-- Les patterns qui distinguent un analyste confirmé.
-- =====================================================================

-- Q14 — Afficher l'arborescence des catégories (chemin parent → enfant).
-- Technique : CTE RÉCURSIVE pour parcourir une hiérarchie auto-référencée.
WITH RECURSIVE arbre AS (
    SELECT id, name, parent_id, name::text AS chemin, 1 AS niveau
    FROM category WHERE parent_id IS NULL
    UNION ALL
    SELECT c.id, c.name, c.parent_id,
           a.chemin || ' > ' || c.name, a.niveau + 1
    FROM category c JOIN arbre a ON c.parent_id = a.id
)
SELECT niveau, chemin FROM arbre ORDER BY chemin;

-- Q15 — Quels produits actifs n'ont JAMAIS été commandés (stock dormant) ?
-- Technique : sous-requête corrélée avec NOT EXISTS (plus lisible/efficace que NOT IN).
SELECT pr.sku, pr.name, pr.price
FROM product pr
WHERE pr.is_active
  AND NOT EXISTS (
      SELECT 1 FROM order_item oi WHERE oi.product_id = pr.id
  )
ORDER BY pr.price DESC
LIMIT 20;

-- Q16 — Pour chaque commande, part de chaque ligne dans le total de la commande.
-- Technique : ratio_to_report via SUM() OVER (PARTITION BY order_id).
SELECT oi.order_id, pr.name,
       oi.quantity * oi.unit_price AS montant_ligne,
       round(100.0 * (oi.quantity * oi.unit_price)
             / sum(oi.quantity * oi.unit_price) OVER (PARTITION BY oi.order_id), 1) AS part_pct
FROM order_item oi
JOIN product pr ON pr.id = oi.product_id
WHERE oi.order_id = 1
ORDER BY montant_ligne DESC;
