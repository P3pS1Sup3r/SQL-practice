WITH CustomerRent AS (
    SELECT
        c.customer_id,
        COUNT(r.rental_id) as customer_rent_count,
        AVG(EXTRACT(DAY FROM (r.return_date - r.rental_date))) as customer_average_rent_days
    FROM customer c
    INNER JOIN rental r ON r.customer_id = c.customer_id
    GROUP BY c.customer_id
),
CustomerFilmCategory AS (
    SELECT 
        c.customer_id,
        fc.category_id,
        COUNT(fc.category_id) AS category_rent_count,
        COUNT(fc.category_id) OVER (PARTITION BY c.customer_id) AS unique_category_rent_count,
        DENSE_RANK() OVER (PARTITION BY c.customer_id ORDER BY COUNT(fc.category_id) DESC, c.customer_id) AS rank
    FROM customer c
    INNER JOIN rental r ON r.customer_id = c.customer_id
    INNER JOIN inventory i ON i.inventory_id = r.inventory_id
    INNER JOIN film f ON f.film_id = i.film_id
    INNER JOIN film_category fc ON fc.film_id = f.film_id
    INNER JOIN category cat ON cat.category_id = fc.category_id
    GROUP BY c.customer_id, fc.category_id
    ORDER BY c.customer_id, category_rent_count DESC
),
FavoriteCategories AS (
    SELECT
        cfc.customer_id,
        cfc.unique_category_rent_count,
        STRING_AGG(cat.name, ', ') as most_rental_category
    FROM CustomerFilmCategory cfc
    INNER JOIN category cat ON cat.category_id = cfc.category_id
    WHERE cfc.rank = 1
    GROUP BY cfc.customer_id, cfc.unique_category_rent_count
)
SELECT
    c.customer_id,
    CONCAT_WS(' ', c.first_name, c.last_name) as fl,
    cr.customer_rent_count,
    cr.customer_average_rent_days,
    ROUND((
        (cr.customer_average_rent_days - AVG(cr.customer_average_rent_days) OVER ()) * 100 /
        AVG(cr.customer_average_rent_days) OVER ()
    ), 2) AS diff_in_average_rent_days,
    fc.unique_category_rent_count,
    fc.most_rental_category
FROM customer c
INNER JOIN CustomerRent cr ON cr.customer_id = c.customer_id
INNER JOIN FavoriteCategories fc ON fc.customer_id = c.customer_id
LIMIT 30