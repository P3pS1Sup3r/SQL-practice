-- Средняя цена блюд в поддереве категории

WITH RECURSIVE CategoryItems AS (
    SELECT
        mi.menu_item_id,
        mi.menu_item_id as anchor_menu_item_id,
        mi.name,
        mi.name as anchor_name,
        mi.kind,
        mi.parent_id,
        mi.price,
        0 as level
    FROM recursive.menu_item mi
    WHERE mi.kind = 'category'
    UNION ALL
    SELECT
        mi.menu_item_id,
        ci.anchor_menu_item_id,
        mi.name,
        ci.anchor_name as anchor_name,
        mi.kind,
        mi.parent_id,
        mi.price,
        ci.level + 1 as level
    FROM recursive.menu_item mi
    INNER JOIN CategoryItems ci ON (mi.parent_id = ci.menu_item_id)
),
CategoryAvgPrice AS (
    SELECT
        ci.anchor_menu_item_id as menu_item_id,
        MAX(ci.anchor_name) as name,
        ROUND(AVG(ci.price), 2) as avg_price
    FROM CategoryItems ci
    WHERE ci.kind = 'dish'
    GROUP BY ci.anchor_menu_item_id
)
SELECT
    *
FROM CategoryAvgPrice ca