-- Вывести всех подчиненных у всех сотрудников

WITH RECURSIVE Subordinate AS (
    SELECT
        e.employee_id,
        CONCAT_WS(' ', e.first_name, e.last_name) AS name,
        e.employee_id AS head_employee_id,
        0 AS level
    FROM recursive.employee e
    UNION ALL
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) AS name,
        s.head_employee_id AS head_employee_id,
        s.level + 1 AS level
    FROM recursive.employee emp
    JOIN Subordinate s ON (emp.manager_id = s.employee_id)
)
SELECT
    e_base.employee_id,
    CONCAT_WS(' ', e_base.first_name, e_base.last_name) AS name,
    COALESCE(subs.subordinate_ids, 'Нет подчиненных') AS subordinate_ids,
    COALESCE(subs.subordinate_names, 'Нет подчиненных') AS subordinate_names
FROM recursive.employee e_base
LEFT JOIN LATERAL (
    SELECT
        STRING_AGG(CAST(s.employee_id AS TEXT), ', ' ORDER BY s.level, s.employee_id) as subordinate_ids,
        STRING_AGG(s.name, ', ' ORDER BY s.level, s.employee_id) as subordinate_names
    FROM Subordinate s
    WHERE s.head_employee_id = e_base.employee_id AND s.level > 0
    GROUP BY s.head_employee_id
) subs ON true

-- Второй вариант через CTE

-- WITH RECURSIVE Subordinate AS (
--     SELECT
--         e.employee_id,
--         CONCAT_WS(' ', e.first_name, e.last_name) AS name,
--         e.employee_id AS head_employee_id,
--         0 AS level
--     FROM recursive.employee e
--     UNION ALL
--     SELECT
--         emp.employee_id,
--         CONCAT_WS(' ', emp.first_name, emp.last_name) AS name,
--         s.head_employee_id AS head_employee_id,
--         s.level + 1 AS level
--     FROM recursive.employee emp
--     JOIN Subordinate s ON (emp.manager_id = s.employee_id)
-- ),
-- AllSubordinates AS (
--     SELECT
--         s.head_employee_id AS employee_id,
--         STRING_AGG(CAST(s.employee_id AS TEXT), ', ' ORDER BY s.employee_id) AS subordinate_ids,
--         STRING_AGG(s.name, ', ' ORDER BY s.employee_id) AS subordinate_names
--     FROM Subordinate s
--     WHERE s.level > 0
--     GROUP BY s.head_employee_id
-- )
-- SELECT
--     e.employee_id,
--     CONCAT_WS(' ', e.first_name, e.last_name) AS name,
--     sub.subordinate_ids,
--     sub.subordinate_names
-- FROM recursive.employee e
-- INNER JOIN AllSubordinates sub ON sub.employee_id = e.employee_id