-- Количество подчинённых на каждом уровне и их суммарная зарплата

WITH RECURSIVE Subordinate AS (
    SELECT
        e.employee_id,
        CONCAT_WS(' ', e.first_name, e.last_name) AS name,
        e.salary,
        e.employee_id AS head_employee_id,
        0 AS level
    FROM recursive.employee e
    UNION ALL
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) AS name,
        emp.salary,
        s.head_employee_id AS head_employee_id,
        s.level + 1 AS level
    FROM recursive.employee emp
    JOIN Subordinate s ON (emp.manager_id = s.employee_id)
)
SELECT
    e_base.employee_id,
    CONCAT_WS(' ', e_base.first_name, e_base.last_name) AS name,
    subs.subordinates_count,
    subs.subordinates_salary
FROM recursive.employee e_base
LEFT JOIN LATERAL (
    SELECT
        COUNT(s.employee_id) as subordinates_count,
        COALESCE(SUM(s.salary), 0) as subordinates_salary
    FROM Subordinate s
    WHERE s.head_employee_id = e_base.employee_id AND s.level > 0
) subs ON true