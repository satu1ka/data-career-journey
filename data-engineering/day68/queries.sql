-- -- Quest 1 — Deduplication
-- WITH actual_order AS (
--     SELECT
--         order_id,
--         event_id,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS last_order
--     FROM orders_incoming_day68
-- )

-- SELECT 
--     order_id,
--     event_id,
--     status,
--     updated_at
-- FROM actual_order
-- WHERE last_order = 1
-- ORDER BY order_id;

-- -- Quest 3 — UPDATE RETURNING
-- UPDATE products_day68
-- SET quantity = quantity + 7
-- WHERE product_id = 104
-- RETURNING 
--     product_id,
--     product_name,
--     quantity;

-- -- Quest 4 — INSERT RETURNING
-- INSERT INTO products_day68 (product_id, product_name, quantity, price)
-- VALUES (105, 'Laptop', 3, 899.90)
-- RETURNING
--     product_id, 
--     product_name,  
--     price;

-- -- Quest 5 — DELETE RETURNING
-- DELETE FROM products_day68
-- WHERE product_id = 105
-- RETURNING
--     product_id,
--     product_name,
--     price;

-- -- Quest 6 — UPSERT + RETURNING
-- WITH actual_order AS (
--     SELECT
--         order_id,
--         event_id,
--         status,
--         amount,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS last_order
--     FROM orders_incoming_day68
-- )

-- INSERT INTO orders_current_day68 (order_id, event_id, status, amount, updated_at)
-- SELECT
--     order_id,
--     event_id,
--     status,
--     amount,
--     updated_at
-- FROM actual_order
-- WHERE last_order = 1
-- ON CONFLICT(order_id)
-- DO UPDATE SET
--     event_id = EXCLUDED.event_id,
--     status = EXCLUDED.status,
--     amount = EXCLUDED.amount,
--     updated_at = EXCLUDED.updated_at
-- WHERE EXCLUDED.updated_at > orders_current_day68.updated_at
-- OR (
--     EXCLUDED.updated_at = orders_current_day68.updated_at 
--     AND EXCLUDED.event_id > orders_current_day68.event_id
-- )
-- RETURNING
--     order_id,
--     event_id,
--     status,
--     updated_at;

-- -- Quest 8 — Первая транзакция
-- BEGIN;

-- UPDATE products_day68
-- SET quantity = quantity + 10
-- WHERE product_id = 104
-- RETURNING
--     product_id, 
--     quantity;

-- ROLLBACK;

-- -- Quest 9 — COMMIT и несколько операций
-- BEGIN;

-- UPDATE products_day68
-- SET quantity = quantity + 5
-- WHERE product_id = 104
-- RETURNING   
--     product_id,
--     quantity;

-- UPDATE products_day68
-- SET quantity = quantity - 3
-- WHERE product_id = 103
-- RETURNING   
--     product_id,
--     quantity;

-- COMMIT;

-- -- Quest 12 — Защита от отрицательных остатков
-- BEGIN;

-- UPDATE products_day68
-- SET quantity = quantity - 5
-- WHERE product_id = 104
-- AND quantity >= 5
-- RETURNING product_id, quantity;

-- ROLLBACK;

-- -- -- Quest 13 — Data Integrity
-- ALTER TABLE products_day68
-- ADD CONSTRAINT non_negative_quantity
-- CHECK (quantity >= 0); 

-- Quest 14 — Проверяем системные ограничения
-- SELECT
--     conname AS constraint_name,
--     contype AS constraint_type,
--     pg_get_constraintdef(oid) AS definition
-- FROM pg_catalog.pg_constraint
-- WHERE conrelid = 'products_day68'::regclass;

-- ALTER TABLE products_day68
-- DROP CONSTRAINT non_negative_quantity;

-- UPDATE products_day68
-- SET quantity = -10
-- WHERE product_id = 104
-- RETURNING
--     product_id,
--     quantity;

-- -- Quest 15 — Data Cleanup + Constraint
-- BEGIN;

-- UPDATE products_day68
-- SET quantity = 0
-- WHERE quantity < 0
-- RETURNING
--     product_id,
--     quantity;

-- ALTER TABLE products_day68
-- ADD CONSTRAINT non_negative_quantity
-- CHECK (quantity >= 0);

-- COMMIT;

-- -- Quest 16 — SAVEPOINT
-- BEGIN;

-- UPDATE products_day68
-- SET quantity = quantity + 10
-- WHERE product_id = 103;

-- SAVEPOINT before_monitor_update;

-- UPDATE products_day68
-- SET quantity = quantity +20
-- WHERE product_id = 104;

-- ROLLBACK TO SAVEPOINT before_monitor_update;

-- COMMIT;

-- -- Quest 17 — SAVEPOINT при SQL-ошибке
-- BEGIN;

-- UPDATE products_day68
-- SET quantity = quantity + 5
-- WHERE product_id = 103;

-- SAVEPOINT before_invalid_update;

-- UPDATE products_day68
-- SET quantity = -10
-- WHERE product_id = 104;

-- ROLLBACK TO SAVEPOINT before_invalid_update;

-- COMMIT;

-- -- Тут проблема клиента, что он не ролбечит после ошибки

-- -- Quest 24 — Защита от Lost Update
-- UPDATE products_day68
-- SET quantity = 7
-- WHERE product_id = 104
-- AND quantity = 12
-- RETURNING   
--     product_id,
--     quantity;

-- Quest 25 — Добавление Version Column
-- ALTER TABLE products_day68
-- ADD column version INTEGER NOT NULL DEFAULT 1;

-- -- Quest 26 — Optimistic Concurrency Control
-- UPDATE products_day68
-- SET 
--     quantity = 20, 
--     version = version + 1
-- WHERE product_id = 104
-- AND version = 1
-- RETURNING 
--     product_id,
--     quantity,
--     version;

-- -- Quest 28 — Retry после Optimistic Lock Conflict
-- UPDATE products_day68
-- SET 
--     quantity = quantity - 5,
--     version = version + 1
-- WHERE product_id = 104
-- AND version = 3
-- AND quantity >= 5
-- RETURNING 
--     product_id,
--     quantity,
--     version;

-- Quest 29 — Diagnosing Failed Updates
SELECT
    quantity,
    version
FROM products_day68
WHERE product_id = 104;