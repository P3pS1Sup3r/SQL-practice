-- Анализировать популярность фильмов по категориям:
-- Для каждой категории фильмов определите топ-5 самых часто арендуемых фильмов
-- Используйте ранжирующие функции с секционированием по категориям

WITH top_film_in_category AS (
    SELECT
        c.name,
        f.title,
        COUNT(r.rental_id) as rent_count,
        DENSE_RANK() OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id) DESC) as film_rank_in_category
    FROM category c
    INNER JOIN film_category fc ON
        fc.category_id = c.category_id
    INNER JOIN film f ON
        f.film_id = fc.film_id
    INNER JOIN inventory i ON
        i.film_id = f.film_id
    INNER JOIN rental r ON
        r.inventory_id = i.inventory_id
    GROUP BY c.name, f.title
    ORDER BY c.name
)
SELECT
	*
FROM top_film_in_category top
WHERE top.film_rank_in_category <= 5
LIMIT 30