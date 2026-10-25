-- -- Quest 1
-- WITH customer_metrics AS (
--     SELECT
--         customer_id,
--         SUM(amount) AS total_revenue,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         ) AS completed_revenue,
--         COALESCE(SUM(amount) FILTER (
--             WHERE status = 'cancelled'
--         ),0
--         ) AS cancelled_revenue,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         )
--         /
--         SUM(amount) AS completed_share
--     FROM orders_day56
--     GROUP BY customer_id
-- )

-- SELECT 
--     customer_id,
--     total_revenue,
--     completed_revenue,
--     cancelled_revenue,
--     completed_share
-- FROM customer_metrics
-- WHERE completed_share >= 0.7;

-- Quest 2
SELECT
    customer_id,
    order_id,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_id
    ) AS previous_amount,
    amount
    -
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_id
    ) AS amount_change
FROM orders_day56;