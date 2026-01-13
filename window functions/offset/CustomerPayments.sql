-- Анализ последовательности платежей клиентов
-- Запрос, который для каждого клиента покажет:
-- Текущий платеж
-- Предыдущий платеж клиента (по дате)
-- Следующий платеж клиента (по дате)
-- Разницу между текущим и предыдущим платежом
-- Количество дней между текущим и предыдущим платежом

SELECT
    c.customer_id,
    CONCAT_WS(' ', c.first_name, c.last_name) as fl,
    p.payment_id,
    p.amount,
    LAG(p.amount) OVER customer_payment_date_desk_window as previous_pay,
    LEAD(p.amount) OVER customer_payment_date_desk_window as next_pay,
    p.amount - COALESCE(LAG(p.amount) OVER customer_payment_date_desk_window, 0) as diff_with_previous_by_amount,
    EXTRACT(DAY FROM (
        p.payment_date - LAG(p.payment_date) OVER customer_payment_date_desk_window
    )) as diff_with_previous_by_days
FROM customer c
INNER JOIN payment p ON p.customer_id = c.customer_id
WINDOW customer_payment_date_desk_window AS (PARTITION BY c.customer_id ORDER BY p.payment_date)
ORDER BY c.customer_id, p.payment_date