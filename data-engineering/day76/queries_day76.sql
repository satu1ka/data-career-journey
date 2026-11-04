-- -- Quest 1 — Простая разминка
-- SELECT
--     order_id,
--     customer_id,
--     amount,
--     order_date
-- FROM practice_orders_day76
-- WHERE status = 'completed'
--     AND amount >= 100
--     AND order_date >= '2026-10-01'
--     AND order_date < '2026-11-01'
-- ORDER BY amount DESC, order_id;

-- -- Quest 2 — JOIN + Aggregation
-- SELECT 
--     pc.customer_id,
--     pc.customer_name,
--     COUNT(po.order_id) AS total_orders,
--     COUNT(po.order_id) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     COALESCE(SUM(po.amount) FILTER (
--         WHERE status = 'completed'
--     ), 
--     0) AS completed_revenue
-- FROM practice_customers_day76 AS pc
-- LEFT JOIN practice_orders_day76 AS po
-- ON pc.customer_id = po.customer_id
-- GROUP BY pc.customer_id
-- ORDER BY completed_revenue DESC, customer_id;

-- -- Quest 3 — GROUP BY + HAVING
-- SELECT 
--     pc.customer_id,
--     pc.customer_name,
--     COUNT(po.order_id) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     COALESCE(SUM(po.amount) FILTER (
--         WHERE status = 'completed'
--     ), 
--     0) AS completed_revenue
-- FROM practice_customers_day76 AS pc
-- JOIN practice_orders_day76 AS po
-- ON pc.customer_id = po.customer_id
-- GROUP BY pc.customer_id
-- HAVING 
--     COUNT(po.order_id) FILTER (
--         WHERE status = 'completed'
--     ) >= 2
-- ORDER BY completed_revenue DESC;

-- -- Quest 4 — CTE + Window Functions
-- WITH last_order AS (
--     SELECT
--         order_id,
--         customer_id,
--         order_date,
--         amount,
--         status,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY order_date DESC, order_id DESC
--         ) AS order_rank
--     FROM practice_orders_day76
-- )

-- SELECT
--     pc.customer_id,
--     pc.customer_name,
--     lo.order_id,
--     lo.order_date,
--     lo.amount,
--     lo.status
-- FROM practice_customers_day76 AS pc
-- LEFT JOIN last_order AS lo
-- ON pc.customer_id = lo.customer_id
--     AND lo.order_rank = 1
-- ORDER BY pc.customer_id;

-- Quest 5 — CASE + Conditional Aggregation
WITH customers_by_city AS (
    SELECT
        pc.city,
        COUNT(DISTINCT pc.customer_id) AS customers_count,
        COUNT(DISTINCT pc.customer_id) FILTER (
            WHERE po.status = 'completed'
        ) AS active_customers,
        COALESCE(SUM(po.amount) FILTER (
            WHERE status = 'completed'
        ), 0) AS completed_revenue
    FROM practice_customers_day76 AS pc
    LEFT JOIN practice_orders_day76 AS po
    ON pc.customer_id = po.customer_id
    GROUP BY pc.city
)

SELECT 
    CASE
        WHEN city IS NULL THEN 'Unknown'
        ELSE city
    END AS city,
    customers_count,
    active_customers,
    completed_revenue
FROM customers_by_city
ORDER BY completed_revenue DESC;