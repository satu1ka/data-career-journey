-- -- Quest 2 — первый subquery руками
-- SELECT 
--     product_name,
--     price
-- FROM products_day40
-- WHERE price > (
--     SELECT AVG(price)
--     FROM products_day40
-- );

-- -- Quest 3 — scalar subquery с другой агрегатной функцией
-- SELECT
--     product_name,
--     price
-- FROM products_day40
-- WHERE price = (
--     SELECT MAX(price)
--     FROM products_day40
-- );

-- -- Quest 4
-- SELECT
--     order_id,
--     customer_id
-- FROM orders_day40
-- WHERE customer_id IN (
--     SELECT customer_id
--     FROM customers_day40
--     WHERE city = 'Berlin'
-- );

-- -- Quest 5 — subquery + aggregation
-- SELECT 
--     order_id
-- FROM order_items_day40
-- GROUP BY order_id
-- HAVING SUM(quantity) > (
--     SELECT AVG(order_total)
--     FROM (
--         SELECT 
--             order_id,
--             SUM(quantity) AS order_total
--         FROM order_items_day40
--         GROUP BY order_id
--     ) AS order_totals
-- );

-- -- Quest 7 — IN subquery в обратную сторону
-- SELECT
--     customer_id,
--     customer_name
-- FROM customers_day40
-- WHERE customer_id IN (
--     SELECT 
--         customer_id
--     FROM orders_day40
--     WHERE status = 'completed'
-- );

-- -- Quest 8 — scalar subquery + outer query
-- SELECT 
--     product_name,
--     price
-- FROM products_day40
-- WHERE price < (
--     SELECT 
--         AVG(price)
--     FROM products_day40
-- );

-- -- Quest 9 — два условия, один из них через subquery
-- SELECT
--     order_id,
--     customer_id,
--     status
-- FROM orders_day40
-- WHERE status = 'completed'
--     AND customer_id IN (
--         SELECT 
--             customer_id
--         FROM customers_day40
--         WHERE city = 'Berlin'
--     );

-- Quest 10
SELECT
    product_name,
    category,
    price
FROM products_day40
WHERE price > (
    SELECT
        AVG(price)
    FROM products_day40
    WHERE category = 'Electronics'
);