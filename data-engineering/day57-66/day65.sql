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
--             WHERE status = 'pending'
--         ), 0) AS pending_revenue,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         )
--         /
--         SUM(amount) AS completed_share
--     FROM orders_day56
--     GROUP BY customer_id
-- )

-- SELECT
--     *
-- FROM customer_metrics
-- WHERE completed_orders >= 2
-- AND completed_share > 0.6;

-- Quest 2
WITH ranking_orders AS (
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
        ) AS amount_rank
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
FROM ranking_orders
WHERE amount_rank = 1
AND amount >= 0.5 * customer_completed_revenue;
