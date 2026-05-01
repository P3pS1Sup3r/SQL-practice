-- Вывести всех подчиненных у сотрудника

WITH RECURSIVE MarySubordinate AS (
    SELECT
        e.employee_id,
        CONCAT_WS(' ', e.first_name, e.last_name) as name,
        e.manager_id,
        1 as level
    FROM recursive.employee e
    WHERE e.employee_id = 2
    UNION ALL
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) as name,
        emp.manager_id,
        ms.level + 1 AS level
    FROM recursive.employee emp
    JOIN MarySubordinate ms ON (emp.manager_id = ms.employee_id)
)
SELECT
    *
FROM MarySubordinate
WHERE level != 1