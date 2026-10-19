-- -- Quest 1
-- with orders_rank AS (
--     SELECT 
--         customer_id,
--         order_id,
--         amount,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY amount DESC, order_id
--         ) AS orders_rank,
--         COUNT(order_id) OVER (
--             PARTITION BY customer_id
--         ) AS completed_orders_count
--     FROM orders_day56
--     WHERE status = 'completed'
-- )

-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     completed_orders_count
-- FROM orders_rank
-- WHERE orders_rank = 1;

-- -- Quest 2 — FILTER + CTE + share
-- WITH pending_metrics AS (
--     SELECT 
--         customer_id,
--         SUM(amount) AS total_revenue,
--         COALESCE(
--             SUM(amount) FILTER (
--                 WHERE status = 'pending')
--                 , 0
--         ) AS pending_revenue,
--         COALESCE(
--             SUM(amount) FILTER (
--                 WHERE status = 'pending')
--                 , 0
--         )
--         /
--         SUM(amount) AS pending_share
--     FROM orders_day56
--     GROUP BY customer_id
-- )

-- SELECT 
--     customer_id,
--     total_revenue,
--     pending_revenue,
--     pending_share
-- FROM pending_metrics
-- WHERE pending_share > 0.2;

-- -- Quest 3
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY order_id
--     ) AS previous_amount,
--     amount
--     -
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY order_id
--     ) AS amount_change
-- FROM orders_day56;
    
-- -- Quest 4 — FILTER + Window
-- SELECT
--     order_id,
--     customer_id,
--     status,
--     amount,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) OVER (
--         PARTITION BY customer_id)  AS customer_completed_revenue,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_total_revenue,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) OVER (
--         PARTITION BY customer_id) 
--     /
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS completed_share
-- FROM orders_day56;

-- Quest 5 — frame + local comparison
WITH orders_with_rolling_avg AS (
    SELECT 
        customer_id,
        order_id,
        amount,
        AVG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_3
    FROM orders_day56
)

SELECT
    customer_id,
    order_id,
    amount,
    rolling_avg_3
FROM orders_with_rolling_avg
WHERE amount > rolling_avg_3;