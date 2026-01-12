WITH CategoryRentsByYearAndMonth AS (
    SELECT
        c.category_id,
        c.name,
        EXTRACT(YEAR FROM(r.rental_date)) as rent_year,
        EXTRACT(MONTH FROM(r.rental_date)) as rent_month,
        COUNT(r.rental_id) as rent_count
    FROM category c
    INNER JOIN film_category fc ON fc.category_id = c.category_id
    INNER JOIN film f ON f.film_id = fc.film_id
    INNER JOIN inventory i ON i.film_id = f.film_id
    INNER JOIN rental r ON r.inventory_id = i.inventory_id
    GROUP BY c.category_id, c.name, rent_year, rent_month
    ORDER BY c.name, rent_year, rent_month
)
SELECT
    cr.*,
    LAG(cr.rent_count) OVER (PARTITION BY cr.name) as prev_month_rent_count,
    ROUND((
        CASE WHEN LAG(cr.rent_count) OVER (PARTITION BY cr.name) IS NULL
            THEN NULL
            ELSE
                (cr.rent_count - LAG(cr.rent_count) OVER (PARTITION BY cr.name)) *
                100 /
                LAG(cr.rent_count) OVER (PARTITION BY cr.name)
        END
    ), 2) as prcent_diff
FROM CategoryRentsByYearAndMonth cr