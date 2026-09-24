-- Day 35 — Aggregates + GROUP BY.

-- COUNT()
-- SUM()
-- AVG()
-- MIN()
-- MAX()

-- -- Quest 1 - все заказы, где есть статус
-- SELECT COUNT(*) AS completed_orders
-- FROM orders
-- WHERE status = 'completed';

-- -- Quest 2
-- SELECT SUM(price) as completed_price_sum
-- FROM orders
-- WHERE status = 'completed';

-- -- Quest 3
-- SELECT SUM(price * quantity) as completed_revenue
-- FROM orders
-- WHERE status = 'completed';

-- -- Quest 4
-- SELECT AVG(price * quantity) as average_completed_revenue
-- FROM orders
-- WHERE status = 'completed';

-- -- Quest 5
-- SELECT 
--     MIN(price * quantity) as min_revenue,
--     MAX(price * quantity) as max_revenue
-- FROM orders
-- WHERE status = 'completed';

-- -- Quest 6
-- SELECT
--     status,
--     COUNT(*) AS orders_count
-- FROM orders
-- GROUP BY status;

-- -- Quest 7
-- SELECT
--     store,
--     COUNT(*) AS orders_count,
--     SUM(price * quantity) AS total_revenue
-- FROM orders
-- GROUP BY store;

-- -- Quest 8
-- SELECT
--     store,
--     COUNT(*) AS orders_count,
--     SUM(price * quantity) AS total_revenue
-- FROM orders
-- WHERE status = 'completed'
-- GROUP BY store;

-- WHERE фильтрует до группировки, HAVING фильтрует готовые группы после GROUP BY

-- -- Quest 9
-- SELECT
--     store,
--     SUM(price * quantity) AS total_revenue
-- FROM orders
-- GROUP BY store
-- HAVING SUM(price * quantity) > 1000;

-- -- Quest 10
-- SELECT
--     store,
--     COUNT(*) as orders_count,
--     SUM(price * quantity) as total_revenue
-- FROM orders
-- WHERE status = 'completed'
-- GROUP BY store
-- HAVING SUM(price * quantity) > 1000;

-- -- Quest 11
-- SELECT
--     store,
--     status,
--     COUNT(*) as orders_count
-- FROM orders
-- GROUP BY store, status;

-- -- Quest 12
-- SELECT
--     store,
--     status,
--     COUNT(*) as orders_count
-- FROM orders
-- GROUP BY store, status 
-- ORDER BY orders_count DESC;

-- -- Quest 13
-- SELECT
--     category,
--     COUNT(*) as orders_count,
--     SUM(price * quantity) as total_revenue,
--     ROUND(AVG(price * quantity), 2) as average_revenue
-- FROM orders
-- GROUP BY category;

-- -- Quest 14
-- SELECT 
--     COUNT(DISTINCT store) as unique_stores
-- FROM orders;

-- -- Quest 15
-- SELECT DISTINCT category
-- FROM orders;

-- -- Quest 16
-- SELECT DISTINCT store, status
-- FROM orders;

-- Quest 17
SELECT
    category,
    COUNT(*) as orders_count,
    SUM(price * quantity) as total_revenue,
    ROUND(AVG(price * quantity), 2) as average_revenue
FROM orders
WHERE status = 'completed'
GROUP BY category
HAVING SUM(price * quantity) > 500
ORDER BY total_revenue DESC;