-- Отчет о прокате фильмов
-- Отчет, который для каждой категории фильмов показывает:
-- Название категории
-- Название фильма
-- Количество прокатов данного фильма
-- Общее количество прокатов в данной категории
-- Долю прокатов фильма от общего количества в его категории (в процентах)
-- Кумулятивную сумму прокатов внутри категории (отсортированную по популярности)

WITH FilmCategoryAggregates AS (
    SELECT
        c.name AS category_name,
        f.title AS film_title,
        c.category_id,
        f.film_id,
        COUNT(r.inventory_id) AS film_rental_count_in_category
    FROM category c
    INNER JOIN film_category fc ON fc.category_id = c.category_id
    INNER JOIN film f ON f.film_id = fc.film_id
    INNER JOIN inventory i ON i.film_id = f.film_id
    INNER JOIN rental r ON r.inventory_id = i.inventory_id
    GROUP BY c.name, f.title, c.category_id, f.film_id
)
SELECT
    fca.category_name,
    fca.film_title,
    fca.film_rental_count_in_category,
    SUM(fca.film_rental_count_in_category) OVER (PARTITION BY fca.category_name) as category_rent_count,
    ROUND(
        CAST(fca.film_rental_count_in_category AS NUMERIC) * 100 /
        SUM(fca.film_rental_count_in_category) OVER (PARTITION BY fca.category_name)
    , 2) as film_rent_percent_from_category_rent,
    SUM(fca.film_rental_count_in_category) OVER (
        PARTITION BY fca.category_name
        ORDER BY fca.film_rental_count_in_category
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_film_rent
FROM FilmCategoryAggregates fca
ORDER BY fca.category_name, fca.film_rental_count_in_category ASC