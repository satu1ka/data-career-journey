-- -- Quest 1 — первое общение с PostgreSQL
-- SELECT 42 as result;

-- -- Quest 2
-- SELECT * 
-- FROM orders;

-- -- Quest 3
-- SELECT order_id, product, status
-- FROM orders;

-- -- Quest 4
-- SELECT order_id, product, price
-- FROM orders
-- WHERE status = 'completed';

-- -- Quest 5
-- SELECT order_id, product, price
-- FROM orders
-- WHERE status = 'completed'
--     AND price >= 100

-- -- Quest 6
-- SELECT order_id, product, status
-- FROM orders
-- WHERE status = 'pending' 
--     OR status = 'cancelled';

-- -- Quest 7
-- SELECT order_id, product, store, status
-- FROM orders
-- WHERE store = 'Store_A' 
--     AND (
--         status = 'completed'
--         OR status = 'cancelled'
--     );

-- -- Quest 8
-- SELECT order_id, product, store, status
-- FROM orders
-- WHERE store = 'Store_A' 
--     AND status IN ('completed', 'cancelled');

-- -- Quest 9
-- SELECT order_id, product, price
-- FROM orders
-- WHERE status = 'completed'
-- ORDER BY price DESC;

-- -- Quest 10
-- SELECT order_id, product, price
-- FROM orders
-- WHERE status = 'completed'
-- ORDER BY price DESC
-- LIMIT 2;

-- -- Quest 11
-- SELECT order_id, product, price, quantity, price * quantity AS revenue
-- FROM orders
-- WHERE status = 'completed'
-- ORDER BY revenue DESC;

-- QUEST 12
SELECT 
    order_id, 
    product, 
    price, 
    quantity, 
    price * quantity AS revenue
FROM orders
WHERE store = 'Store_A' 
    AND status = 'completed'
ORDER BY revenue DESC
LIMIT 2;