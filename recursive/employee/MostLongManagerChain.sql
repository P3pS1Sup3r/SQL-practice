--- Самая длинная цепочка подчинённых

WITH RECURSIVE Managers AS (
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) as name,
        emp.manager_id,
        emp.employee_id as anchor_employee_id,
        0 as level
    FROM recursive.employee emp
    UNION ALL
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) as name,
        emp.manager_id,
        m.anchor_employee_id,
        m.level + 1 as level
    FROM recursive.employee emp
    JOIN Managers m ON (emp.employee_id = m.manager_id)
),
EmployeeManagersCount AS (
    SELECT
        e_base.employee_id,
        CONCAT_WS(' ', e_base.first_name, e_base.last_name) as name,
        employee_managers.managers_count,
        DENSE_RANK() OVER (ORDER BY employee_managers.managers_count DESC) as rank
    FROM recursive.employee e_base
    LEFT JOIN LATERAL (
        SELECT
            COUNT(m.employee_id) as managers_count
        FROM Managers m
        WHERE e_base.employee_id = m.anchor_employee_id AND m.level > 0
    ) as employee_managers on TRUE
)
SELECT
    emc.employee_id,
    emc.name,
    emc.managers_count
FROM EmployeeManagersCount emc
WHERE emc.rank = 1