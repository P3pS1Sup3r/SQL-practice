WITH FilmRentsByYearAndMonth AS (
    SELECT
        f.film_id,
        f.title,
        EXTRACT(YEAR FROM(r.rental_date)) as rent_year,
        EXTRACT(MONTH FROM(r.rental_date)) as rent_month,
        COUNT(r.rental_id) as month_rent_count
    FROM film f
    INNER JOIN inventory i ON i.film_id = f.film_id
    INNER JOIN rental r ON r.inventory_id = i.inventory_id
    GROUP BY f.film_id, f.title, rent_year, rent_month
    ORDER BY f.film_id, rent_year, rent_month
)
SELECT
    fr.*,
    FIRST_VALUE(fr.month_rent_count) OVER (PARTITION BY fr.film_id, fr.rent_year) as first_month_rent_count,
    ROUND((
        (fr.month_rent_count - FIRST_VALUE(fr.month_rent_count) OVER (PARTITION BY fr.film_id, fr.rent_year)) *
        100 /
        FIRST_VALUE(fr.month_rent_count) OVER (PARTITION BY fr.film_id, fr.rent_year)
    ), 2) AS diff_with_first_rent_mount,
    ROUND(
        AVG(fr.month_rent_count) OVER (PARTITION BY fr.film_id, fr.rent_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    , 2) AS three_month_avg
FROM FilmRentsByYearAndMonth fr