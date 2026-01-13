-- Анализ изменения длительности аренды
-- Запрос, который покажет для каждой аренды:
-- ID аренды
-- ID клиента
-- Дату аренды
-- Дату возврата
-- Продолжительность аренды в днях
-- Продолжительность предыдущей аренды этого же клиента
-- Изменение в продолжительности по сравнению с предыдущей арендой (в процентах)

SELECT
    r.rental_id,
    c.customer_id,
    CONCAT_WS(' ', c.first_name, c.last_name) as name,
    r.rental_date,
    r.return_date,
    EXTRACT(DAY FROM (r.return_date - r.rental_date)) as rent_days,
    LAG(EXTRACT(DAY FROM (r.return_date - r.rental_date))) OVER customer_rental_window as prev_rent_days,
    ROUND((
        CASE WHEN EXTRACT(DAY FROM(r.return_date - r.rental_date)) = 0
            THEN 0
            ELSE (
                EXTRACT (DAY FROM(
                    (r.return_date - r.rental_date) -
                    LAG(r.return_date - r.rental_date) OVER customer_rental_window
                )) /
                EXTRACT(DAY FROM(r.return_date - r.rental_date)) *
                100
            )
        END
    ), 2) as percent_rent_days_diff
FROM customer c
INNER JOIN rental r ON r.customer_id = c.customer_id
WINDOW customer_rental_window as (PARTITION BY c.customer_id ORDER BY r.rental_date)
ORDER BY c.customer_id, r.rental_date