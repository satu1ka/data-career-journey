-- -- Quest 3
-- SELECT customer_name AS name
-- FROM customers_day40

-- UNION ALL

-- SELECT product_name
-- FROM products_day40;

-- -- Quest 4
-- SELECT customer_name AS name
-- FROM customers_day40

-- UNION ALL

-- SELECT product_name
-- FROM products_day40
-- ORDER BY name;

-- -- Quest 5
-- SELECT 
--     customer_name AS name,
--     'customer' AS source
-- FROM customers_day40

-- UNION ALL

-- SELECT 
--     product_name AS name,
--     'product' AS source
-- FROM products_day40
-- ORDER BY source, name;

-- Quest 7 — финальный на сегодня
SELECT
    customer_name AS name,
    'customer' AS source
FROM customers_day40 AS c
WHERE c.city = 'Berlin'

UNION ALL

SELECT
    product_name AS name,
    'product' AS source
FROM products_day40 AS p
WHERE p.category = 'Electronics'
ORDER BY source, name;