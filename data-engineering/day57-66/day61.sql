-- -- Quest 1
-- WITH customer_metrics AS (
--     SELECT
--         customer_id,
--         COUNT(order_id) AS total_orders,
--         COUNT(order_id) FILTER (
--             WHERE status = 'completed'
--         ) AS completed_orders,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         ) AS completed_revenue,
--         COALESCE(SUM(amount) FILTER (
--             WHERE status = 'pending')
--             , 0
--         ) AS pending_revenue
--     FROM orders_day56
--     GROUP BY customer_id
-- )

-- SELECT
--     *
-- FROM client_metrics 
-- WHERE completed_orders >= 2
-- AND completed_revenue > pending_revenue;

-- Quest 2
WITH completed_orders_with_metrics AS (
    SELECT
        customer_id,
        order_id,
        amount,
        SUM(amount) OVER (
            PARTITION BY customer_id
        ) AS customer_completed_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY amount DESC, order_id
        ) AS row_rank
    FROM orders_day56
    WHERE status = 'completed'
)

SELECT 
    customer_id,
    order_id,
    amount,
    customer_completed_revenue,
    amount 
    /
    customer_completed_revenue AS order_share
FROM completed_orders_with_metrics
WHERE row_rank = 1
AND amount > 0.6 * customer_completed_revenue;

