-- Анализ тенденций платежей во времени
-- Запрос, который покажет месячную статистику платежей:
-- Месяц (в формате YYYY-MM)
-- Общую сумму платежей за месяц
-- Средний платеж за месяц
-- Накопительный итог (бегущую сумму) платежей с начала года
-- Процентное изменение по сравнению с предыдущим месяцем

WITH PaymentByMonth AS (
    SELECT
        TO_CHAR(r.rental_date, 'YYYY') as rent_year,
        TO_CHAR(r.rental_date, 'YYYY-MM') as rent_month,
        SUM(p.amount) as month_payment,
        ROUND(AVG(p.amount), 2) as month_payment_average
    FROM rental r
    INNER JOIN payment p ON p.rental_id = r.rental_id
    GROUP BY rent_year, rent_month
    ORDER BY rent_year, rent_month
)
SELECT
    pbm.rent_month,
    pbm.month_payment,
    pbm.month_payment_average,
    SUM(pbm.month_payment) OVER (
        PARTITION BY pbm.rent_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as year_cumulative_payment,
    CASE
        WHEN LAG(pbm.month_payment) OVER (ORDER BY pbm.rent_month) IS NULL THEN NULL
        ELSE ROUND((
            (pbm.month_payment - LAG(pbm.month_payment) OVER (ORDER BY pbm.rent_month)) * 100 /
            LAG(pbm.month_payment) OVER (ORDER BY pbm.rent_month)
        ), 2)
    END AS percent_change_from_prev_month
FROM PaymentByMonth pbm
