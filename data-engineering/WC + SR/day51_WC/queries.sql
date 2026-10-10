-- -- Quest 1 — business requirement → SQL
-- SELECT 
--     customer_name
-- FROM customers_day40 AS c
-- WHERE EXISTS (
--     SELECT 1 FROM orders_day40 AS o
--     WHERE c.customer_id = o.customer_id AND o.status = 'completed'
-- )
-- AND NOT EXISTS (
--     SELECT 1 FROM orders_day40 AS o
--     WHERE c.customer_id = o.customer_id AND o.status = 'pending'
-- );

-- -- Quest 2 — grain + LEFT JOIN
-- SELECT
--     c.customer_name,
--     COUNT(DISTINCT o.order_id) AS completed_orders,
--     COALESCE(SUM(oi.quantity), 0) AS items_count
-- FROM customers_day40 AS c
-- LEFT JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
--     AND o.status = 'completed'
-- LEFT JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
-- GROUP BY c.customer_id;

-- -- Quest 3 — CAST / NULLIF / DQ
-- SELECT 
--     order_id,
--     CAST(NULLIF(price, '') AS NUMERIC) AS typed_price,
--     CAST(NULLIF(NULLIF(quantity, ''), '0') AS INTEGER) AS typed_quantity,
--     CAST(NULLIF(price, '') AS NUMERIC)
--     *
--     CAST(NULLIF(NULLIF(quantity, ''), '0') AS INTEGER)
--     AS revenue
-- FROM staging_orders;

-- Quest 8 — финальный integration challenge
WITH eligible_completed_orders AS (
    SELECT 
        c.customer_id, 
        c.customer_name,
        o.order_id
    FROM customers_day40 AS c
    JOIN orders_day40 AS o
        ON c.customer_id = o.customer_id
        AND o.status = 'completed'
    WHERE NOT EXISTS (
        SELECT 1 FROM orders_day40 AS po
        WHERE c.customer_id = po.customer_id 
        AND po.status = 'pending'
    )
),

customer_revenue AS (
    SELECT
        eco.customer_id,
        eco.customer_name,
        eco.order_id,
        (p.price * oi.quantity) AS line_revenue
    FROM eligible_completed_orders AS eco
    JOIN order_items_day40 AS oi
        ON eco.order_id = oi.order_id
    JOIN products_day40 AS p
        ON oi.product_id = p.product_id
),

customer_summary AS (
    SELECT
        cr.customer_id,
        cr.customer_name,
        COUNT(DISTINCT cr.order_id) AS completed_orders,
        SUM(line_revenue) AS total_revenue
    FROM customer_revenue AS cr
    GROUP BY 
        cr.customer_id,
        cr.customer_name
)

SELECT 
    cs.customer_name,
    cs.completed_orders,
    cs.total_revenue
FROM customer_summary AS cs
WHERE cs.total_revenue > 500
ORDER BY total_revenue DESC;