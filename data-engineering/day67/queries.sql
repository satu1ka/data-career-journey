-- -- Quest 1
-- WITH latest_order AS (
--     SELECT
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS latest_order
--     FROM orders_raw
-- )

-- SELECT 
--     order_id,
--     amount,
--     status,
--     updated_at
-- FROM latest_order
-- WHERE latest_order = 1
-- ORDER BY order_id;

-- -- Quest 4 — Latest orders aggregation
-- WITH latest_order AS (
--     SELECT
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS latest_order
--     FROM orders_raw
-- )

-- SELECT 
--     status,
--     COUNT(order_id) AS orders_count,
--     SUM(amount) AS total_amount
-- FROM latest_order
-- WHERE latest_order = 1
-- GROUP BY status
-- ORDER BY status;

-- -- Quest 9 - Insert
-- INSERT INTO products_day67 (product_id, product_name, quantity, price)
-- VALUES (104, 'Monitor', 5, 249.90);

-- -- Quest 10 - Update
-- UPDATE products_day67
-- SET quantity = products_day67.quantity + 12
-- WHERE product_id = 104;

-- -- Quest 11 — DELETE
-- DELETE FROM products_day67
-- WHERE product_id = 101;

-- SELECT * FROM products_day67;

-- -- Quest 12 — CREATE TABLE
-- CREATE TABLE products_archive_day67 (
--     product_id INTEGER PRIMARY KEY,
--     product_name VARCHAR(100) NOT NULL,
--     quantity INTEGER DEFAULT 0,
--     price NUMERIC(10,2) NOT NULL
-- );

-- -- Quest 13 — Изменение структуры таблицы
-- ALTER TABLE products_archive_day67  
-- ALTER COLUMN quantity SET NOT NULL;

-- -- Quest 14 — Подготовка данных к изменению схемы
-- UPDATE products_archive_day67
-- SET quantity = 0
-- WHERE quantity IS NULL;

-- ALTER TABLE products_archive_day67  
-- ALTER COLUMN quantity SET NOT NULL;

-- -- Quest 15 — DROP TABLE
-- DROP TABLE IF EXISTS products_archive_day67;
-- SELECT * FROM products_archive_day67;

-- -- Quest 16 — Первый ON CONFLICT
-- INSERT INTO products_day67 (product_id, product_name, quantity, price)
-- VALUES (104, 'Monitor Pro', 10, 399.90)
-- ON CONFLICT(product_id)
-- DO NOTHING;

-- SELECT * FROM products_day67;

-- -- Quest 17 — Первый UPSERT
-- INSERT INTO products_day67 (product_id, product_name, quantity, price)
-- VALUES (104, 'Monitor Pro', 10, 399.90)
-- ON CONFLICT(product_id)
-- DO UPDATE SET
--     product_name = EXCLUDED.product_name,
--     quantity = EXCLUDED.quantity,
--     price = EXCLUDED.price;

-- SELECT * FROM products_day67;

-- -- Quest 18 — Conditional UPSERT
-- INSERT INTO products_day67 (product_id, product_name, quantity, price)
-- VALUES (104, 'Monitor Ultra', 15, 349.90)
-- ON CONFLICT(product_id)
-- DO UPDATE SET
--     product_name = EXCLUDED.product_name,
--     quantity = EXCLUDED.quantity,
--     price = EXCLUDED.price
-- WHERE EXCLUDED.price > products_day67.price;

-- SELECT * FROM products_day67;

-- -- Quest 19 — Conditional UPSERT для заказов
-- INSERT INTO orders_current (order_id, event_id, amount, status, updated_at)
-- SELECT 
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at
-- FROM orders_incoming
-- WHERE event_id = 11
-- ON CONFLICT(order_id)
-- DO UPDATE SET
--     event_id = EXCLUDED.event_id,
--     amount = EXCLUDED.amount,
--     status = EXCLUDED.status,
--     updated_at = EXCLUDED.updated_at
-- WHERE EXCLUDED.updated_at > orders_current.updated_at
-- OR (EXCLUDED.updated_at = orders_current.updated_at
--     AND EXCLUDED.event_id > orders_current.event_id);

-- SELECT * FROM orders_current;

-- -- Quest 21 — Deduplication before UPSERT
-- WITH latest_order AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS rn
--     FROM orders_incoming
-- )

-- SELECT 
--     event_id,
--     order_id,
--     amount,
--     status,
--     updated_at
-- FROM latest_order
-- WHERE rn = 1;

-- Quest 22 — Batch UPSERT с дедупликацией
WITH latest_order AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY updated_at DESC, event_id DESC
        ) AS rn
    FROM orders_incoming
)

INSERT INTO orders_current (order_id, event_id, amount, status, updated_at)
SELECT 
    order_id,
    event_id,
    amount,
    status,
    updated_at
FROM latest_order
WHERE rn = 1
ON CONFLICT(order_id)
DO UPDATE SET
    event_id = EXCLUDED.event_id,
    amount = EXCLUDED.amount,
    status = EXCLUDED.status,
    updated_at = EXCLUDED.updated_at
WHERE EXCLUDED.updated_at > orders_current.updated_at
OR (EXCLUDED.updated_at = orders_current.updated_at
    AND EXCLUDED.event_id > orders_current.event_id);

SELECT * FROM orders_current;