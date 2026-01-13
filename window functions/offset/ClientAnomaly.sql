-- Обнаружение резких изменений в поведении клиентов
-- Случаи, когда клиенты резко меняли свои привычки аренды:
-- Клиент, который раньше арендовал только фильмы одной категории, но затем переключился на другую
-- Клиенты, у которых сумма платежа резко отличается от их обычной суммы (более чем на 50%)
-- Клиенты, у которых интервал между арендами внезапно увеличился или уменьшился в 2 и более раза

WITH CustomerRentsDuration AS (
    SELECT
        c.customer_id,
        CONCAT_WS(' ', c.first_name, c.last_name) as name,
        r.rental_id,
        r.rental_date,
        EXTRACT(DAY FROM(
            r.rental_date - LAG(r.rental_date) OVER customer_window
        )) as interval_between_rents
    FROM customer c
    INNER JOIN rental r ON r.customer_id = c.customer_id
    WINDOW customer_window as (PARTITION BY c.customer_id ORDER BY r.rental_date)
    ORDER BY c.customer_id, r.rental_date
),
CustomerRentsAnomaly AS (
    SELECT
        crd.customer_id,
        crd.name,
        AVG(crd.interval_between_rents) as avg_interval,
        MAX(crd.interval_between_rents) as max_interval,
        CASE WHEN MAX(crd.interval_between_rents) > AVG(crd.interval_between_rents) * 5
            THEN TRUE
            ELSE FALSE
        END AS has_anomaly_with_rents
    FROM CustomerRentsDuration crd
    GROUP BY crd.customer_id, crd.name
),
CustomerAvgPayment AS (
    SELECT
        c.customer_id,
        CONCAT_WS(' ', c.first_name, c.last_name) as name,
        r.rental_id,
        p.amount,
        AVG(p.amount) OVER (PARTITION BY c.customer_id) AS customer_average_payment,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY p.amount DESC) AS number
    FROM customer c
    INNER JOIN rental r ON r.customer_id = c.customer_id
    INNER JOIN payment p ON p.rental_id = r.rental_id
    ORDER BY c.customer_id, p.amount
),
CustomerPaymentAnomaly AS (
    SELECT
        cap.customer_id,
        cap.name,
        cap.customer_average_payment * 1.5 AS customer_average_payment,
        MAX(cap.amount) AS max_payment_except_three_last,
        CASE WHEN MAX(cap.amount) > cap.customer_average_payment * 1.5
            THEN TRUE
            ELSE FALSE
        END AS has_anomaly_with_payments
    FROM CustomerAvgPayment cap
    WHERE cap.number > 3
    GROUP BY cap.customer_id, cap.name, cap.customer_average_payment
    ORDER BY cap.customer_id
),
MedianDates AS (
    SELECT
        customer_id,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM rental_date)) AS median_date_epoch
    FROM rental
    GROUP BY customer_id
),
CustomerCategoryRents AS (
    SELECT
        c.customer_id,
        r.rental_id,
        r.rental_date,
        cat.category_id,
        cat.name
    FROM customer c
    INNER JOIN rental r ON r.customer_id = c.customer_id
    INNER JOIN inventory i ON i.inventory_id = r.inventory_id
    INNER JOIN film_category fc ON fc.film_id = i.film_id
    INNER JOIN category cat ON cat.category_id = fc.category_id
    ORDER BY c.customer_id, cat.category_id
),
CustomerEarlyCategoryRents AS (
    SELECT
        ccr.customer_id,
        ccr.category_id,
        ccr.name,
        COUNT(ccr.category_id) AS category_rent_count,
        DENSE_RANK() OVER (PARTITION BY ccr.customer_id ORDER BY COUNT(ccr.category_id) DESC) AS rank
    FROM CustomerCategoryRents ccr
    INNER JOIN MedianDates md ON md.customer_id = ccr.customer_id AND ccr.rental_date < to_timestamp(md.median_date_epoch)
    GROUP BY ccr.customer_id, ccr.category_id, ccr.name
    ORDER BY ccr.customer_id, ccr.category_id
),
CustomerLateCategoryRents AS (
    SELECT
        ccr.customer_id,
        ccr.category_id,
        ccr.name,
        COUNT(ccr.category_id) AS category_rent_count,
        DENSE_RANK() OVER (PARTITION BY ccr.customer_id ORDER BY COUNT(ccr.category_id) DESC) AS rank
    FROM CustomerCategoryRents ccr
    INNER JOIN MedianDates md ON md.customer_id = ccr.customer_id AND ccr.rental_date >= to_timestamp(md.median_date_epoch)
    GROUP BY ccr.customer_id, ccr.category_id, ccr.name
    ORDER BY ccr.customer_id, ccr.category_id
),
CustomerCategoryRentsAnomaly AS (
    SELECT
        c.customer_id,
        CONCAT_WS(' ', c.first_name, c.last_name) as customer_name,
        string_agg(e.name, ', ') as early_most_vieved_category,
        string_agg(l.name, ', ') as late_most_vieved_category,
        CASE WHEN string_agg(e.name, ', ') != string_agg(l.name, ', ')
            THEN TRUE
            ELSE FALSE
        END AS has_anomaly_with_categorys
    FROM customer c
    LEFT JOIN CustomerEarlyCategoryRents e ON e.customer_id = c.customer_id AND e.rank = 1
    LEFT JOIN CustomerLateCategoryRents l ON l.customer_id = c.customer_id AND l.rank = 1
    GROUP BY c.customer_id, customer_name
)
SELECT
    c.customer_id,
    cra.has_anomaly_with_rents,
    cpa.has_anomaly_with_payments,
    cca.has_anomaly_with_categorys
FROM customer c
INNER JOIN CustomerRentsAnomaly cra ON cra.customer_id = c.customer_id
INNER JOIN CustomerPaymentAnomaly cpa ON cpa.customer_id = c.customer_id
INNER JOIN CustomerCategoryRentsAnomaly cca ON cca.customer_id = c.customer_id