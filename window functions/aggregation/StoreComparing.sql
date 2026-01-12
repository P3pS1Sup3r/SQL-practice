WITH StorePaymentByWeeks as (
    SELECT
        s.store_id,
        TO_CHAR(p.payment_date, 'YYYY:WW') as payment_week,
        COUNT(p.payment_date) as payment_week_count,
        SUM(p.amount) as payment_week_amount,
        AVG(p.amount) as payment_week_avarage
    FROM store s
    INNER JOIN inventory i ON
        i.store_id = s.store_id
    INNER JOIN rental r ON
        r.inventory_id = i.inventory_id
    INNER JOIN payment p ON
        p.rental_id = r.rental_id
    GROUP BY s.store_id, TO_CHAR(p.payment_date, 'YYYY:WW')
)
SELECT
    spw.store_id,
    spw.payment_week,
    spw.payment_week_count,
    spw.payment_week_amount,
    ROUND((
        spw.payment_week_amount /
        (SUM(spw.payment_week_amount) OVER payment_week_window) * 100
    ), 2) as store_week_profit_percent,
    ROUND((
        spw.payment_week_avarage /
        (SUM(spw.payment_week_avarage) OVER payment_week_window) * 100
    ), 2) as store_week_average_profit_percent
FROM StorePaymentByWeeks spw
WINDOW payment_week_window AS (PARTITION BY spw.payment_week ORDER BY spw.payment_week)
ORDER BY spw.payment_week, spw.store_id