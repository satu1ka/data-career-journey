-- Day 81 — Data Modeling: Table Grain & JOIN Cardinality
-- -- Quest 1 — Предсказываем результат JOIN
-- SELECT
--     o.order_id,
--     oi.item_id,
--     p.payment_id
-- FROM orders_day81 AS o
-- LEFT JOIN order_items_day81 AS oi
--     ON o.order_id = oi.order_id
-- LEFT JOIN payments_day81 AS p
--     ON o.order_id = p.order_id
-- WHERE o.order_id = 1001
-- ORDER BY oi.item_id, p.payment_id;

-- -- Quest 2 — Предсказываем Join Fanout
-- SELECT
--     o.order_id,
--     SUM(p.amount) AS total_payments
-- FROM orders_day81 AS o
-- LEFT JOIN order_items_day81 AS oi
--     ON o.order_id = oi.order_id
-- LEFT JOIN payments_day81 AS p
--     ON o.order_id = p.order_id
-- WHERE o.order_id = 1003
-- GROUP BY o.order_id;

-- -- Quest 3 — Исправляем Join Fanout
-- WITH order_metrics AS (
--     SELECT
--         order_id,
--         SUM(amount) FILTER (
--             WHERE payment_status = 'captured'
--         ) AS order_amount
--     FROM payments_day81
--     GROUP BY order_id
-- ),
-- item_metrics AS (
--     SELECT order_id,
--         COUNT(*) AS items_in_order
--     FROM order_items_day81
--     GROUP BY order_id
-- )

-- SELECT 
--     o.order_id,
--     COALESCE(im.items_in_order, 0) AS items_count,
--     COALESCE(om.order_amount, 0) AS captured_amount
-- FROM orders_day81 AS o
-- LEFT JOIN item_metrics AS im
-- ON o.order_id = im.order_id
-- LEFT JOIN order_metrics AS om
-- ON o.order_id = om.order_id;

-- Quest 4 - проверка левого запроса
SELECT
    o.order_id,
    COUNT(oi.item_id) AS items_count,
    COUNT(p.payment_id) AS payments_count,
    COALESCE(
        SUM(p.amount) FILTER (
            WHERE p.payment_status = 'captured'
        ), 0
    ) AS captured_amount
FROM orders_day81 AS o
LEFT JOIN order_items_day81 AS oi
    ON o.order_id = oi.order_id
LEFT JOIN payments_day81 AS p
    ON o.order_id = p.order_id
WHERE o.order_id = 1001
GROUP BY o.order_id;
