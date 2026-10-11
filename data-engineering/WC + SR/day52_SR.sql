-- ============================================================
-- DAY 52 — SUNDAY REVIEW
-- Focus: grain, LEFT JOIN filters, COUNT(DISTINCT)
-- ============================================================


-- 1. Keep all customers, count only completed orders.
-- Important:
-- filtering in ON preserves customers without completed orders.

SELECT
    c.customer_name,
    COUNT(o.order_id) AS completed_orders
FROM customers_day40 AS c
LEFT JOIN orders_day40 AS o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
GROUP BY c.customer_id
ORDER BY completed_orders DESC;


-- 2. JOIN to order_items changes the grain:
-- before JOIN:
--     1 row = 1 order
--
-- after JOIN:
--     1 row = 1 product line inside 1 order
--
-- Therefore COUNT(*) counts product lines,
-- while COUNT(DISTINCT o.order_id) counts actual orders.

SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS orders_count,
    COALESCE(SUM(oi.quantity), 0) AS items_count
FROM customers_day40 AS c
LEFT JOIN orders_day40 AS o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
LEFT JOIN order_items_day40 AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY orders_count DESC;


-- Main review rule:
--
-- grain = what one row represents
-- metric = a value calculated for that row / group
--
-- LEFT JOIN + filter in ON:
--     keeps unmatched left rows
--
-- LEFT JOIN + filter in WHERE:
--     may remove unmatched left rows