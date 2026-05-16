-- Сколько блюд в поддереве каждой категории

WITH RECURSIVE CategorySubTree AS (
    SELECT
        mi.menu_item_id,
        mi.menu_item_id as anchor_menu_item_id,
        mi.name,
        mi.name as anchor_name,
        mi.parent_id,
        mi.kind,
        0 as level
    FROM recursive.menu_item mi
    WHERE mi.kind = 'category'
    UNION ALL
    SELECT
        mi.menu_item_id,
        cst.anchor_menu_item_id,
        mi.name,
        cst.anchor_name,
        mi.parent_id,
        mi.kind,
        cst.level + 1 as level
    FROM recursive.menu_item mi
    INNER JOIN CategorySubTree cst ON (mi.parent_id = cst.menu_item_id)
),
CategoryDishCount AS (
    SELECT
        cst.anchor_menu_item_id as menu_item_id,
        cst.anchor_name as name,
        COUNT(cst.menu_item_id) as dish_count
    FROM CategorySubTree cst
    WHERE cst.kind = 'dish' AND cst.level > 0
    GROUP BY cst.anchor_menu_item_id, cst.anchor_name
)
SELECT
    cdc.menu_item_id,
    cdc.name,
    cdc.dish_count
FROM CategoryDishCount cdc