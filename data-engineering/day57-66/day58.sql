-- -- Quest 1
-- WITH orders_with_last_2_avg AS (
--     SELECT
--         order_id,
--         customer_id,
--         status,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY order_id
--             ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--         ) AS previous_2_avg
--     FROM orders_day56
-- )

-- SELECT
--     order_id,
--     customer_id,
--     status,
--     amount,
--     previous_2_avg
-- FROM orders_with_last_2_avg
-- WHERE status = 'completed'
--     AND amount > previous_2_avg;

-- Quest 2 — короткий FILTER + share
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders,
    COUNT(order_id) FILTER (
        WHERE status = 'completed'
    ) AS completed_orders,
    COUNT(order_id) FILTER (
        WHERE status = 'pending'
    ) AS pending_orders,
    COUNT(order_id) FILTER (
        WHERE status = 'completed'
    )::NUMERIC
    /
    COUNT(order_id) AS completed_share
FROM orders_day56
GROUP BY customer_id;

