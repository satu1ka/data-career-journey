-- -- Quest 1
-- SELECT 
--     order_id,
--     customer_id,
--     status,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_total_revenue,
--     SUM(amount) FILTER (
--         WHERE status = 'completed')
--         OVER (
--         PARTITION BY customer_id
--     ) AS customer_completed_revenue,
--     SUM(amount) FILTER (
--         WHERE status = 'completed')
--         OVER (
--         PARTITION BY customer_id
--     )
--     /
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS completed_share
-- FROM orders_day56;

-- Quest 2
WITH customer_metrics AS (
    SELECT
        customer_id,
        SUM(amount) FILTER (
            WHERE status = 'completed'
        ) AS completed_revenue,
        COALESCE(
            SUM(amount) FILTER (
                WHERE status = 'pending'
            ), 
            0
        ) AS pending_revenue,
        COUNT(order_id) FILTER (
            WHERE status = 'completed'
        ) AS completed_orders
    FROM orders_day56
    GROUP BY customer_id
)

SELECT
    customer_id,
    completed_revenue,
    pending_revenue,
    completed_orders
FROM customers_orders
WHERE completed_revenue > pending_revenue;