-- -- Quest 3 - NOT EXIST
-- SELECT
--     c.customer_name
-- FROM customers_day40 AS c
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM orders_day40 AS o
--     WHERE c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- );

-- -- Quest 8 — correlated EXISTS + несколько таблиц
-- SELECT 
--     c.customer_name
-- FROM customers_day40 AS c
-- WHERE EXISTS (
--     SELECT 1
--     FROM orders_day40 AS o
--     JOIN order_items_day40 AS oi
--         ON o.order_id = oi.order_id
--     JOIN products_day40 AS p
--         ON oi.product_id = p.product_id
--     WHERE c.customer_id = o.customer_id
--         AND p.category = 'Electronics'
--         AND o.status = 'completed'
-- );

-- Quest 10 — финальный на Day 47
SELECT 
    c.customer_name
FROM customers_day40 AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders_day40 AS o
    JOIN order_items_day40 AS oi
        ON o.order_id = oi.order_id
    JOIN products_day40 AS p
        ON oi.product_id = p.product_id
    WHERE c.customer_id = o.customer_id
        AND p.category = 'Electronics'
        AND o.status = 'completed'
);