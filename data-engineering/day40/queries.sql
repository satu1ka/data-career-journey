-- -- Quest 3
-- SELECT
--     o.order_id,
--     c.customer_name,
--     p.product_name,
--     oi.quantity
-- FROM customers_day40 AS c
-- JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id;

-- -- Quest 5 — revenue per order
-- SELECT
--     o.order_id,
--     c.customer_name,
--     SUM(p.price * oi.quantity) AS order_revenue
-- FROM customers_day40 AS c
-- JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id
-- GROUP BY o.order_id, c.customer_name
-- ORDER BY order_revenue DESC;

-- -- Quest 7 — отчёт по клиентам
-- SELECT
--     c.customer_name,
--     COUNT(DISTINCT o.order_id) AS orders_count,
--     SUM(oi.quantity) AS products_count,
--     SUM(p.price * oi.quantity) as total_revenue
-- FROM customers_day40 AS c
-- JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id
-- GROUP BY c.customer_id
-- ORDER BY total_revenue DESC;

-- -- Quest 8
-- SELECT
--     c.customer_name,
--     COUNT(DISTINCT o.order_id) AS completed_orders,
--     COUNT(DISTINCT oi.product_id) AS distinct_products,
--     COALESCE(SUM(oi.quantity), 0) AS products_count,
--     COALESCE(SUM(p.price * oi.quantity), 0) AS total_revenue  
-- FROM customers_day40 AS c
-- LEFT JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- LEFT JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- LEFT JOIN products_day40 AS p
--     ON oi.product_id = p.product_id
-- GROUP BY c.customer_id
-- ORDER BY total_revenue DESC;

-- -- Quest 9
-- SELECT 
--     p.product_name,
--     COUNT(DISTINCT c.customer_id) AS customers_count,
--     COUNT(DISTINCT o.order_id) AS orders_count,
--     SUM(oi.quantity) AS units_sold,
--     SUM(p.price * oi.quantity) AS total_revenue  
-- FROM customers_day40 AS c
-- JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id
-- GROUP BY p.product_id
-- ORDER BY total_revenue DESC;

-- Quest 12
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) AS orders_count,
    COUNT(DISTINCT c.customer_id) AS customers_count,
    COUNT(DISTINCT p.product_id) AS distinct_products,
    SUM(oi.quantity) AS units_sold,
    SUM(p.price * oi.quantity) AS total_revenue
FROM customers_day40 AS c
JOIN orders_day40 AS o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
JOIN order_items_day40 AS oi
    ON o.order_id = oi.order_id
JOIN products_day40 AS p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;