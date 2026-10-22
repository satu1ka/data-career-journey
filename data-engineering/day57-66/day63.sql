-- -- Quest 1  
-- SELECT 
--     customer_id,
--     COUNT(order_id) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_orders,
--     COALESCE(SUM(amount) FILTER (
--         WHERE status = 'pending'
--     ), 0) AS pending_revenue,
--     AVG(amount) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_avg_amount
-- FROM orders_day56
-- GROUP BY customer_id;

-- Quest 2
WITH customer_metrics AS (
    SELECT
        customer_id,
        SUM(amount) FILTER (
            WHERE status = 'completed'
        ) AS completed_revenue,
        COALESCE(SUM(amount) FILTER (
            WHERE status = 'pending'
        ), 0) AS pending_revenue,
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
FROM customer_metrics
WHERE completed_revenue > pending_revenue;