--- Вывести хлебные крошки для блюд
--- Для каждого блюда вывести один столбец — путь от корня до блюда, например: "Меню / Обед / Вторые блюда / Паста карбонара"

WITH RECURSIVE MenuBreadcrumbs AS (
    SELECT
        mi.menu_item_id,
        mi.menu_item_id as anchor_menu_item_id,
        mi.name,
        mi.parent_id,
        0 as level
    FROM recursive.menu_item mi
    WHERE mi.kind = 'dish'
    UNION ALL
    SELECT
        mi.menu_item_id,
        mb.anchor_menu_item_id,
        mi.name,
        mi.parent_id,
        mb.level + 1 as level
    FROM recursive.menu_item mi
    INNER JOIN MenuBreadcrumbs mb ON (mb.parent_id = mi.menu_item_id)
),
AggregatedMenuBreadcrumbs AS (
    SELECT
        mb.anchor_menu_item_id,
        STRING_AGG(mb.name, ' / ' ORDER BY mb.level DESC) as breadcrumb
    FROM MenuBreadcrumbs mb
    GROUP BY mb.anchor_menu_item_id
)
SELECT
    mi.menu_item_id,
    mi.name,
    amb.breadcrumb
FROM recursive.menu_item mi
INNER JOIN AggregatedMenuBreadcrumbs amb ON amb.anchor_menu_item_id = mi.menu_item_id