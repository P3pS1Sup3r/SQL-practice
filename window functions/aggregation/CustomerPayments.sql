-- Анализ платежей клиентов
-- Запрос, который покажет для каждого платежа:
-- Сумму платежа
-- Общую сумму всех платежей клиента
-- Среднюю сумму платежа клиента
-- Процент текущего платежа от общей суммы платежей клиента
-- Разницу между текущим платежом и средним платежом клиента

SELECT 
    p.payment_id,
    p.amount,
    SUM(p.amount) OVER customer_window as total_customer_payment,
    ROUND(AVG(p.amount) OVER customer_window, 2) as average_customer_payment,
    ROUND((p.amount / SUM(p.amount) OVER customer_window) * 100, 2) as payment_percent_of_total,
    ROUND((p.amount - AVG(p.amount) OVER customer_window), 2) as diff_from_average,
    CONCAT_WS(' ', c.first_name, c.last_name) as customer_name
FROM payment p
INNER JOIN rental r ON
	r.rental_id = p.rental_id
INNER JOIN customer c ON
	c.customer_id = p.customer_id
WINDOW customer_window AS (PARTITION BY c.customer_id)
LIMIT 100