SELECT
    c.category_id,
    c.name,
    COUNT(r.rental_id) as rent_count,
    DENSE_RANK() OVER (ORDER BY COUNT(r.rental_id) DESC) as category_rank
FROM category c
INNER JOIN film_category fc ON
    fc.category_id = c.category_id
INNER JOIN film f ON
    f.film_id = fc.film_id
INNER JOIN inventory i ON
    i.film_id = f.film_id
INNER JOIN rental r ON
    r.inventory_id = i.inventory_id
GROUP BY c.category_id
ORDER BY category_rank ASC
LIMIT 30