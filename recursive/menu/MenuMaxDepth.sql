-- Максимальная вложенность меню

WITH RECURSIVE MenuItemParents AS (
    SELECT
        mi.menu_item_id,
        mi.menu_item_id as anchor_menu_item_id,
        mi.name,
        mi.name as anchor_name,
        mi.parent_id,
        0 as level
    FROM recursive.menu_item mi
    UNION ALL
    SELECT
        mi.menu_item_id,
        mip.anchor_menu_item_id,
        mi.name,
        mip.name as anchor_name,
        mi.parent_id,
        mip.level + 1 as level
    FROM recursive.menu_item mi
    INNER JOIN MenuItemParents mip ON (mip.parent_id = mi.menu_item_id)
),
RankedMenuItemsPath AS (
    SELECT
        mip.anchor_menu_item_id as menu_item_id,
        STRING_AGG(mip.name, ' -> ' ORDER BY mip.level DESC) as path,
        DENSE_RANK() OVER (ORDER BY MAX(mip.level) DESC) as path_long_rank
    FROM MenuItemParents mip
    GROUP BY mip.anchor_menu_item_id
)
SELECT
	rmip.menu_item_id,
  rmip.path
FROM RankedMenuItemsPath rmip
WHERE rmip.path_long_rank = 1