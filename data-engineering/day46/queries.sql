-- -- Quest 4
-- SELECT
--     d.date,
--     s.store,
--     COALESCE(sd.revenue, 0) AS revenue
-- FROM dates_day46 AS d
-- CROSS JOIN stores_day46 AS s
-- LEFT JOIN sales_day46 AS sd
--     ON d.date = sd.date 
--     AND s.store = sd.store;

-- -- Quest 7
-- WITH avg_price AS (
--     SELECT AVG(price) AS avg_price
--     FROM products_day40
-- )

-- SELECT 
--     p.product_name,
--     p.price,
--     ap.avg_price AS avg_price
-- FROM products_day40 AS p
-- CROSS JOIN avg_price AS ap;

-- -- Quest 8
-- WITH avg_price AS (
--     SELECT AVG(price) AS avg_price
--     FROM products_day40
-- )

-- SELECT
--     p.product_name,
--     p.price,
--     ROUND(ap.avg_price, 2)
-- FROM products_day40 AS p
-- CROSS JOIN avg_price AS ap
-- WHERE p.price > ap.avg_price
-- ORDER BY price DESC;

-- Quest 10 — финальный на сегодня
WITH avg_category_price AS (
    SELECT
        category,
        AVG(price) AS avg_category_price
    FROM products_day40
    GROUP BY category
)

SELECT 
    p.product_name,
    p.category,
    p.price,
    acp.avg_category_price
FROM products_day40 AS p
JOIN avg_category_price AS acp
    ON p.category = acp.category
WHERE p.price > acp.avg_category_price
ORDER BY price DESC;