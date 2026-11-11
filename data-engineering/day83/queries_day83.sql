-- -- Data Modeling: Normalization & Data Anomalies
-- SELECT *
-- FROM orders_flat_day83
-- ORDER BY order_id, item_id;

-- -- Quest 2 — Нормализуем таблицу
-- -- нормализовали в голове

-- -- Quest 3 — Реализуем нормализованную модель
-- CREATE TABLE customers_day83 (
--     customer_id INTEGER PRIMARY KEY,
--     customer_name TEXT NOT NULL,
--     customer_city TEXT NOT NULL
-- );

-- CREATE TABLE orders_day83 (
--     order_id INTEGER PRIMARY KEY,
--     order_date DATE NOT NULL,
--     customer_id INTEGER NOT NULL REFERENCES customers_day83(customer_id)
-- );

-- CREATE TABLE order_items_day83 (
--     order_id INTEGER NOT NULL REFERENCES orders_day83(order_id),
--     item_id INTEGER NOT NULL,
--     product_name TEXT NOT NULL,
--     quantity INTEGER NOT NULL CHECK (quantity > 0),
--     unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
--     PRIMARY KEY (order_id, item_id)
-- );

-- -- Quest 4.1 — Перенос покупателей
-- INSERT INTO customers_day83 (customer_id, customer_name, customer_city)
-- SELECT DISTINCT
--     customer_id,
--     customer_name,
--     customer_city
-- FROM orders_flat_day83
-- RETURNING customer_id, customer_name, customer_city;

-- -- Quest 4.2 — Перенос заказов
-- INSERT INTO orders_day83 (order_id, order_date, customer_id)
-- SELECT DISTINCT
--     order_id,
--     order_date,
--     customer_id
-- FROM orders_flat_day83
-- RETURNING order_id, order_date, customer_id;

-- -- Quest 4.3 — Перенос товарных позиций
-- INSERT INTO order_items_day83 (order_id, item_id, product_name, quantity, unit_price)
-- SELECT
--     order_id,
--     item_id,
--     product_name,
--     quantity,
--     unit_price
-- FROM orders_flat_day83
-- RETURNING order_id, item_id, product_name, quantity, unit_price;

-- -- Quest 4.4 — Data Migration Verification
-- SELECT
--     COUNT(DISTINCT customer_id) AS original_number_of_customers,
--     COUNT(DISTINCT order_id) AS original_nummber_of_orders,
--     COUNT(*) AS original_number_of_items_in_orders
-- FROM orders_flat_day83;

-- WITH customers_count AS (
--     SELECT
--         COUNT(*) AS number_of_customers
--     FROM customers_day83
-- ),
-- orders_count AS (
--     SELECT 
--         COUNT(*) AS number_of_orders
--     FROM orders_day83
-- ),
-- orders_items_count AS (
--     SELECT
--         COUNT(*) AS number_of_items
--     FROM order_items_day83
-- )
-- SELECT 
--     cc.number_of_customers,
--     oc.number_of_orders,
--     oi.number_of_items
-- FROM customers_count AS cc
-- CROSS JOIN orders_count AS oc
-- CROSS JOIN orders_items_count AS oi;

-- -- Quest 4.5 — Data Reconciliation: проверяем значения
-- SELECT 
--     of.order_id,
--     of.item_id,
--     of.unit_price AS source_price,
--     oi.unit_price AS target_price
-- FROM orders_flat_day83 AS of
-- LEFT JOIN order_items_day83 AS oi
-- ON of.order_id = oi.order_id 
-- AND of.item_id = oi.item_id
-- WHERE of.unit_price IS DISTINCT FROM oi.unit_price
-- OR oi.item_id IS NULL;

-- Quest 4.7 — Финальное закрепление
SELECT
    oi.order_id,
    oi.item_id,
    oi.product_name
FROM order_items_day83 AS oi
LEFT JOIN orders_flat_day83 AS of
ON oi.order_id = of.order_id 
AND oi.item_id = of.item_id
WHERE of.item_id IS NULL;