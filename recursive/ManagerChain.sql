-- Цепочка начальников и уровень иерархии сотрудника

WITH RECURSIVE Managers AS (
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) as name,
        emp.manager_id,
        emp.employee_id as head_employee_id,
        0 as level
    FROM recursive.employee emp
    UNION ALL
    SELECT
        emp.employee_id,
        CONCAT_WS(' ', emp.first_name, emp.last_name) as name,
        emp.manager_id,
        m.head_employee_id,
        m.level + 1 as level
    FROM recursive.employee emp
    JOIN Managers m ON (emp.employee_id = m.manager_id)
)
SELECT
    e_base.employee_id,
    CONCAT_WS(' ', e_base.first_name, e_base.last_name) as name,
    employee_managers.employee_level,
    employee_managers.managers_chain
FROM recursive.employee e_base
LEFT JOIN LATERAL (
    SELECT
        COALESCE(STRING_AGG(m.name, ' → '), 'Нет начальников') as managers_chain,
        COALESCE(MAX(m.level), 0) as employee_level
    FROM Managers m
    WHERE e_base.employee_id = m.head_employee_id AND m.level > 0
) as employee_managers on TRUE