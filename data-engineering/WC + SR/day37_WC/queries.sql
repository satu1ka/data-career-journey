-- -- Quest 1 — Filtering + calculated column + sorting
-- SELECT
--     order_id,
--     product,
--     store,
--     price,
--     quantity,
--     price * quantity AS revenue
-- FROM orders
-- WHERE 
--     status = 'completed'
--     AND store = 'Store_A'
--     AND price * quantity >= 500
-- ORDER BY revenue DESC;

-- -- Quest 2 — Aggregation + HAVING
-- SELECT 
--     category,
--     COUNT(*) AS orders_count,
--     SUM(price * quantity) AS total_revenue,
--     ROUND(AVG(price * quantity), 2) AS average_revenue
-- FROM orders
-- WHERE status = 'completed'
-- GROUP BY category
-- HAVING SUM(price * quantity) > 500
-- ORDER BY total_revenue DESC;

-- -- Quest 4 — NULL + COUNT
-- SELECT  
--     COUNT(*) AS all_orders,
--     COUNT(promo_code) AS promo_orders,
--     COUNT(*) - COUNT(promo_code) AS orders_without_promo
-- FROM orders_day36;

-- -- Quest 5 — CASE + даты
-- SELECT
--     order_id,
--     created_at,
--     CASE
--         WHEN EXTRACT(HOUR FROM created_at) < 12 THEN 'morning'
--         WHEN EXTRACT(HOUR FROM created_at) < 18 THEN 'afternoon'
--         ELSE 'evening'
--     END as time_of_day
-- FROM orders_day36;

-- -- Quest 7 — Conditional aggregation
-- SELECT
--     store,
--     COUNT(*) AS orders_count,
--     SUM(
--         CASE
--             WHEN status = 'completed' THEN 1
--             ELSE 0
--         END
--     ) AS completed_orders,
--     SUM(
--         CASE
--             WHEN status = 'cancelled' THEN 1
--             ELSE 0
--         END
--     ) AS cancelled_orders,
--     SUM(
--         CASE
--             WHEN promo_code IS NOT NULL THEN 1
--             ELSE 0
--         END
--     ) AS promo_orders
-- FROM orders_day36
-- GROUP BY store;

-- Quest 10 — финальный integration challenge
SELECT
    DATE_TRUNC('day', created_at) AS order_day,
    COUNT(*) AS orders_count,
    SUM(
        CASE
            WHEN status = 'completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders,
    SUM(
        CASE
            WHEN promo_code IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS promo_orders,
    SUM(price * quantity) AS total_revenue,
    ROUND(AVG(price * quantity), 2) AS average_revenue
FROM orders_day36
GROUP BY order_day
HAVING SUM(price * quantity) > 500
ORDER BY order_day;