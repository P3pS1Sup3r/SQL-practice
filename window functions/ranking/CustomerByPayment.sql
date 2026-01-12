SELECT 
    c.customer_id,
    CONCAT_WS(' ', c.last_name, c.first_name) as LF,
    SUM(p.amount) as total_payment,
    ROW_NUMBER() OVER total_payment_desc_window as row_number,
    RANK() OVER total_payment_desc_window as rank,
    DENSE_RANK() OVER total_payment_desc_window as dense_rank
FROM customer c
INNER JOIN payment p
    ON p.customer_id = c.customer_id
GROUP BY c.customer_id
WINDOW total_payment_desc_window AS (ORDER BY SUM(p.amount) DESC)
ORDER BY total_payment DESC

LIMIT 15