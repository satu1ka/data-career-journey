-- -- Quest 1 — самостоятельно выбрать инструменты
-- SELECT
--     c.customer_name,
--     COUNT(DISTINCT o.order_id) AS completed_orders,
--     COUNT(DISTINCT p.product_id) AS distinct_products,
--     COALESCE(SUM(oi.quantity), 0) AS units_bought,
--     COALESCE(SUM(p.price * oi.quantity), 0) AS total_revenue
-- FROM customers_day40 AS c
-- LEFT JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- LEFT JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- LEFT JOIN products_day40 as p
--     ON oi.product_id = p.product_id
-- GROUP BY c.customer_id
-- ORDER BY total_revenue DESC;

-- -- Quest 2 — UNION ALL
-- SELECT 
--     order_id,
--     customer_id,
--     'completed_batch' AS batch
-- FROM orders_day40
-- WHERE status = 'completed'

-- UNION ALL

-- SELECT
--     order_id,
--     customer_id,
--     'pending_batch' AS batch
-- FROM orders_day40
-- WHERE status = 'pending'
-- ORDER BY batch, order_id;

-- -- Quest 3 CTE с нуля
-- WITH completed_orders AS (
--     SELECT
--         order_id
--     FROM orders_day40
--     WHERE status = 'completed'
-- ),
-- line_revenue AS (
--     SELECT
--         oi.order_id, 
--         p.price * oi.quantity AS line_revenue
--     FROM products_day40 AS p
--     JOIN order_items_day40 AS oi
--         ON p.product_id = oi.product_id
-- )

-- SELECT 
--     co.order_id,
--     SUM(lr.line_revenue) AS order_revenue
-- FROM completed_orders AS co
-- LEFT JOIN line_revenue AS lr
--     ON co.order_id = lr.order_id
-- GROUP BY co.order_id
-- ORDER BY order_revenue DESC;

-- -- Quest 4 — Subquery, без CTE
-- SELECT
--     product_name,
--     category,
--     price
-- FROM products_day40
-- WHERE price > (
--     SELECT 
--         AVG(price)
--     FROM products_day40
-- )
-- ORDER BY price DESC;

-- -- Toje samoe, no s CTE
-- WITH avg_price AS (
--     SELECT 
--         AVG(price) AS avg_price
--     FROM products_day40
-- )

-- SELECT 
--     product_name,
--     category,
--     price
-- FROM products_day40 AS p
-- CROSS JOIN avg_price AS ap
-- WHERE p.price > ap.avg_price;

-- Quest 8 — финальный integration challenge
WITH completed_orders AS (
    SELECT 
        order_id,
        customer_id
    FROM orders_day40
    WHERE status = 'completed'
),
customer_summary AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(DISTINCT co.order_id) AS completed_orders,
        SUM(p.price * oi.quantity) AS total_revenue
    FROM completed_orders AS co
    JOIN customers_day40 AS c
        ON co.customer_id = c.customer_id
    JOIN order_items_day40 AS oi
        ON co.order_id = oi.order_id
    JOIN products_day40 AS p
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id
)

SELECT
    customer_name,
    completed_orders,
    total_revenue
FROM customer_summary
WHERE total_revenue > (
    SELECT 
        AVG(total_revenue)
    FROM customer_summary
)
ORDER BY total_revenue DESC;