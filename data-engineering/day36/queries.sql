-- Что такое NULL
-- NULL — это не:
-- 0
-- ''
-- 'NULL'
-- False
-- NULL означает примерно:
-- значение отсутствует / неизвестно / не определено.

-- -- Quest 1
-- SELECT 
--     COUNT(*) AS orders_without_promo
-- FROM orders_day36
-- WHERE promo_code IS NULL;

-- Quest 2
-- SELECT
--     COUNT(*) AS shipped_orders
-- FROM orders_day36
-- WHERE shipped_at IS NOT NULL;

-- -- Quest 3
-- SELECT
--     COUNT(*) AS all_orders,
--     COUNT(promo_code) AS orders_with_promo
-- FROM orders_day36;

-- -- Quest 4
-- SELECT
--     order_id,
--     COALESCE(promo_code, 'NO_PROMO') AS promo_display
-- FROM orders_day36;

-- -- Quest 5
-- SELECT
--     order_id,
--     product,
--     price,
--     CASE
--         WHEN price >= 500 THEN 'high'
--         WHEN price >= 100 THEN 'medium'
--         ELSE 'low'
--     END AS price_segment
-- FROM orders_day36;

-- -- Quest 6
-- SELECT
--     order_id,
--     status,
--     shipped_at,
--     CASE
--         WHEN shipped_at IS NOT NULL THEN 'shipped'
--         WHEN status = 'cancelled' THEN 'cancelled'
--         ELSE 'waiting'
--     END as delivery_state
-- FROM orders_day36;

-- -- Quest 7
-- SELECT 
--     order_id,
--     created_at,
--     EXTRACT(HOUR FROM created_at) AS order_hour
-- FROM orders_day36;

-- Для выборки всего дня надёжный паттерн такой:
-- WHERE created_at >= '2026-09-21'
--   AND created_at < '2026-09-22'

-- -- Quest 8
-- SELECT
--     order_id,
--     product,
--     created_at
-- FROM orders_day36
-- WHERE created_at >= '2026-09-21'
--     AND created_at < '2026-09-22';

-- -- Quest 9
-- SELECT 
--     order_id,
--     created_at,
--     shipped_at,
--     shipped_at - created_at AS shipping_time
-- FROM orders_day36
-- WHERE shipped_at IS NOT NULL;

-- DATE_TRUNC().
-- Она «обрезает» дату/время до нужного уровня. Например, на другой таблице:
-- SELECT
--     DATE_TRUNC('day', event_time) AS event_day
-- FROM events;
-- Если было:
-- 2026-09-25 14:37:52
-- получим:
-- 2026-09-25 00:00:00

-- -- Quest 10
-- SELECT
--     DATE_TRUNC('day', created_at) as order_day,
--     COUNT(*) as orders_count
-- FROM orders_day36
-- GROUP BY order_day;

-- -- Quest 11
-- SELECT
--     DATE_TRUNC('day', created_at) AS order_day,
--     COUNT(*) AS orders_count,
--     SUM(price * quantity) AS total_revenue
-- FROM orders_day36
-- WHERE status = 'completed'
-- GROUP BY order_day
-- ORDER BY order_day ASC;

-- -- Quest 12
-- SELECT
--     order_id,
--     created_at,
--     CASE
--         WHEN EXTRACT(HOUR FROM created_at) < 12 THEN 'morning'
--         WHEN EXTRACT(HOUR FROM created_at) < 18 THEN 'afternoon'
--         ELSE 'evening'
--     END AS time_of_day
-- FROM orders_day36;

-- -- Quest 13
-- SELECT
--     CASE
--         WHEN EXTRACT(HOUR FROM created_at) < 12 THEN 'morning'
--         WHEN EXTRACT(HOUR FROM created_at) < 18 THEN 'afternoon'
--         ELSE 'evening'
--     END AS time_of_day,
--     COUNT(*) AS orders_count,
--     SUM(price * quantity) AS total_revenue
-- FROM orders_day36
-- WHERE status = 'completed'
-- GROUP BY time_of_day
-- ORDER BY total_revenue DESC;

-- -- Quest 14
-- SELECT
--     DATE_TRUNC('day', created_at) as order_day,
--     COUNT(*) AS orders_count,
--     COUNT(shipped_at) AS shipped_orders,
--     COUNT(promo_code) AS orders_with_promo,
--     SUM(price * quantity) AS total_revenue
-- FROM orders_day36
-- WHERE status = 'completed'
-- GROUP BY order_day
-- ORDER BY order_day;

-- -- Quest 15
-- SELECT
--     store,
--     COUNT(*) AS orders_count,
--     SUM(
--         CASE
--             WHEN status = 'completed' THEN 1
--             ELSE 0
--         END
--     ) AS completed_orders
-- FROM orders_day36
-- GROUP BY store;

-- Quest 16
SELECT
    store,
    COUNT(*) as orders_count,
    SUM(
        CASE
            WHEN status = 'completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders,
    SUM(
        CASE
            WHEN shipped_at IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS shipped_orders,
    SUM(
        CASE
            WHEN promo_code IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS promo_orders
FROM orders_day36
GROUP BY store;