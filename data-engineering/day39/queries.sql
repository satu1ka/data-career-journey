-- -- Quest 1
-- SELECT 
--     o.order_id,
--     c.customer_name,
--     o.amount,
--     o.status
-- FROM customers_day39 AS c
-- JOIN orders_day39 AS o
--     ON c.customer_id = o.customer_id;

-- -- Quest 4 — LEFT JOIN руками
-- SELECT 
--     c.customer_name,
--     c.city,
--     o.order_id,
--     o.amount
-- FROM customers_day39 AS c
-- LEFT JOIN orders_day39 AS o
--     ON c.customer_id = o.customer_id;
    
-- -- Quest 5
-- SELECT
--     c.customer_name,
--     COUNT(o.order_id) AS orders_count
-- FROM customers_day39 AS c
-- LEFT JOIN orders_day39 as o
--     ON c.customer_id = o.customer_id
-- GROUP BY c.customer_id
-- ORDER BY orders_count DESC;

-- -- Quest 7
-- SELECT 
--     c.customer_name,
--     COUNT(o.order_id) AS completed_orders
-- FROM customers_day39 AS c
-- LEFT JOIN orders_day39 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- GROUP BY c.customer_id
-- ORDER BY completed_orders DESC;

-- -- Quest 8
-- SELECT
--     c.customer_name,
--     COUNT(o.order_id) AS completed_orders,
--     -- тут интересный момент:
--     -- COUNT(no rows) → 0
--     -- SUM(no values) → NULL 
--     -- поэтому строка ниже, вместо NULL там, где нет значений выдаст 0
--     COALESCE(SUM(o.amount), 0) AS completed_revenue
-- FROM customers_day39 AS c
-- LEFT JOIN orders_day39 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- GROUP BY c.customer_id
-- ORDER BY completed_revenue DESC;

-- Quest 10 — финальный на сегодня
SELECT
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS completed_orders,
    COALESCE(SUM(o.amount), 0) AS completed_revenue
FROM customers_day39 AS c
LEFT JOIN orders_day39 AS o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
GROUP BY c.customer_id
ORDER BY completed_revenue DESC;