-- -- Quest 2
-- WITH completed_orders AS (
--     SELECT *
--     FROM orders_day40
--     WHERE status = 'completed'
-- )

-- SELECT
--     order_id,
--     customer_id
-- FROM completed_orders;

-- -- Quest 3
-- WITH completed_orders AS (
--     SELECT * 
--     FROM orders_day40
--     WHERE status = 'completed'
-- )

-- SELECT 
--     co.order_id,
--     c.customer_name
-- FROM completed_orders AS co 
-- JOIN customers_day40 AS c
--     ON co.customer_id = c.customer_id;

-- -- Quest 4
-- WITH 
-- completed_orders AS (
--     SELECT *
--     FROM orders_day40
--     WHERE status = 'completed'
-- ),

-- completed_orders_items AS (
--     SELECT 
--         co.order_id,
--         oi.product_id,
--         oi.quantity
--     FROM completed_orders AS co
--     JOIN order_items_day40 AS oi
--         ON co.order_id = oi.order_id
-- )

-- SELECT 
--     coi.order_id,
--     coi.product_id,
--     coi.quantity
-- FROM completed_orders_items AS coi;

-- -- Quest 5
-- WITH 
-- completed_orders AS (
--     SELECT *
--     FROM orders_day40
--     WHERE status = 'completed'
-- ),

-- completed_orders_items AS (
--     SELECT 
--         co.order_id,
--         oi.product_id,
--         oi.quantity
--     FROM completed_orders AS co
--     JOIN order_items_day40 AS oi
--         ON co.order_id = oi.order_id
-- )

-- SELECT 
--     coi.order_id,
--     p.product_name,
--     coi.quantity
-- FROM completed_orders_items AS coi
-- JOIN products_day40 AS p
--     ON coi.product_id = p.product_id;

-- -- Quest 6
-- WITH 
-- completed_orders AS (
--     SELECT *
--     FROM orders_day40
--     WHERE status = 'completed'
-- ),
-- completed_orders_items AS (
--     SELECT 
--         co.order_id,
--         oi.product_id,
--         oi.quantity
--     FROM completed_orders AS co
--     JOIN order_items_day40 AS oi
--         ON co.order_id = oi.order_id
-- ),
-- order_lines AS (
--     SELECT 
--         coi.order_id,
--         p.price * coi.quantity AS line_revenue
--     FROM completed_orders_items AS coi
--     JOIN products_day40 AS p
--         ON coi.product_id = p.product_id
-- )

-- SELECT 
--     ol.order_id,
--     SUM(ol.line_revenue) AS order_revenue
-- FROM order_lines AS ol
-- GROUP BY ol.order_id;

-- Quest 7
WITH 
completed_orders AS (
    SELECT *
    FROM orders_day40
    WHERE status = 'completed'
),
completed_orders_items AS (
    SELECT 
        co.order_id,
        oi.product_id,
        oi.quantity
    FROM completed_orders AS co
    JOIN order_items_day40 AS oi
        ON co.order_id = oi.order_id
),
order_lines AS (
    SELECT 
        coi.order_id,
        p.price * coi.quantity AS line_revenue
    FROM completed_orders_items AS coi
    JOIN products_day40 AS p
        ON coi.product_id = p.product_id
),
order_summary AS (
    SELECT
        ol.order_id,
        SUM(ol.line_revenue) AS order_revenue
    FROM order_lines AS ol
    GROUP BY ol.order_id
)

SELECT 
    os.order_id,
    os.order_revenue
FROM order_summary AS os
ORDER BY os.order_revenue DESC;
