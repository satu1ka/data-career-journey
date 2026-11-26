-- -- Bonus Mixed SQL Practice
-- -- Quest 1 — Customer Revenue Ranking
-- WITH customer_metrics AS (
--     SELECT
--         customer_id,
--         COUNT(order_id) AS orders_count,
--         SUM(revenue) AS total_revenue,
--         ROUND(SUM(revenue) 
--         /
--         COUNT(order_id), 2) AS avg_order_value
--     FROM fact_orders_day95
--     GROUP BY customer_id
-- )

-- SELECT 
--     *,
--     DENSE_RANK() OVER (
--         ORDER BY total_revenue DESC
--     ) AS revenue_rank
-- FROM customer_metrics
-- ORDER BY revenue_rank, customer_id;

-- -- Quest 2 — The Revenue Inflation Bug
-- SELECT
--     a.customer_id,
--     COUNT(a.order_id) AS orders_count,
--     SUM(a.revenue) AS total_revenue
-- FROM fact_orders_day95 AS a
-- JOIN fact_orders_day95 AS b
--     ON a.customer_id = b.customer_id
-- GROUP BY a.customer_id
-- HAVING COUNT(a.order_id) >= 2
-- ORDER BY total_revenue DESC;

-- -- чо зачем ^

-- SELECT
--     customer_id,
--     COUNT(order_id) AS orders_count,
--     SUM(revenue) AS total_revenue
-- FROM fact_orders_day95 
-- GROUP BY customer_id
-- HAVING COUNT(order_id) >= 2
-- ORDER BY total_revenue DESC;

-- Bonus Quest 3 — The Latest Order Bug
WITH last_order_for_customer AS (
    SELECT
        customer_id,
        order_id AS latest_order_id,
        order_date AS latest_order_date,
        revenue AS latest_order_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY order_date DESC, order_id DESC
        ) AS last_order
    FROM fact_orders_day95
)
SELECT
    customer_id,
    latest_order_id,
    latest_order_date,
    latest_order_revenue
FROM last_order_for_customer
WHERE last_order = 1
ORDER BY customer_id;