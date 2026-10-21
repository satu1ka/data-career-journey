-- -- Quest 1
-- SELECT
--     customer_id,
--     SUM(amount) AS total_revenue,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_revenue,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     )
--     /
--     SUM(amount) AS completed_share
-- FROM orders_day56
-- GROUP BY customer_id;

-- Quest 2
SELECT
    customer_id,
    COUNT(order_id) FILTER (
        WHERE status = 'completed'
    ) AS completed_orders,
    SUM(amount) FILTER (
        WHERE status = 'completed'
    ) AS completed_revenue
FROM orders_day56
GROUP BY customer_id
HAVING COUNT(order_id) FILTER (
        WHERE status = 'completed'
    ) >= 2;