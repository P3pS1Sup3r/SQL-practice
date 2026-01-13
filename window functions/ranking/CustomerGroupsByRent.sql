-- Определить распределение клиентов по активности:
-- Разделите клиентов на квартили по количеству аренд
-- Используйте функции NTILE() и PERCENT_RANK()

SELECT
	c.customer_id,
	CONCAT_WS(' ', c.first_name, c.last_name) as fl,
    COUNT(r.rental_id) as rent_count,
    NTILE(3) OVER (ORDER BY COUNT(r.rental_id) DESC) as groups_ntile,
    PERCENT_RANK() OVER (ORDER BY COUNT(r.rental_id) ASC) as percent_rank
FROM customer c
INNER JOIN rental r ON
	r.customer_id = c.customer_id
GROUP BY c.customer_id