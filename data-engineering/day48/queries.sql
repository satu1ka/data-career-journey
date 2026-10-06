-- -- Quest 4
-- SELECT 
--     c.customer_id
-- FROM customers_day40 AS c
-- JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
-- WHERE o.status = 'completed'

-- EXCEPT

-- SELECT 
--     c.customer_id
-- FROM customers_day40 AS c
-- JOIN orders_day40 AS o
--     ON c.customer_id = o.customer_id
-- WHERE o.status = 'pending';

-- Quest 5
SELECT
    customer_id
FROM orders_day40
WHERE status = 'completed'

INTERSECT

SELECT
    customer_id
FROM orders_day40
WHERE status = 'pending';