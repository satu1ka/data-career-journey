-- -- Quest 1
-- SELECT  
--     customer_id,
--     COUNT(order_id) AS total_orders,
--     COUNT(order_id) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_revenue
-- FROM orders_day56   
-- GROUP BY customer_id;

-- Quest 2
SELECT
    customer_id,
    SUM(amount) AS total_revenue,
    COALESCE(SUM(amount) FILTER (
        WHERE status = 'pending'
        ),
        0
    ) AS pending_revenue,
    COALESCE(SUM(amount) FILTER (
        WHERE status = 'pending'
        ),
        0
    )
    /
    SUM(amount) AS pending_share
FROM orders_day56  
GROUP BY customer_id;