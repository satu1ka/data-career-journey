-- Dimensional Modeling: Facts, Dimensions & Star Schema

-- Quest 2 — Проектируем Star Schema
-- Quest 2.2 — Переходим к DDL
-- CREATE TABLE dim_customers_day84 (
--     customer_id   INTEGER PRIMARY KEY,
--     customer_name TEXT NOT NULL,
--     city          TEXT NOT NULL
-- );

-- CREATE TABLE dim_products_day84 (
--     product_id    INTEGER PRIMARY KEY,
--     product_name  TEXT NOT NULL,
--     category      TEXT NOT NULL,
--     catalog_price NUMERIC(10, 2) NOT NULL CHECK (catalog_price > 0)
-- );

-- CREATE TABLE fact_sales_day84 (
--     order_id            INTEGER NOT NULL,
--     item_id             INTEGER NOT NULL,
--     product_id          INTEGER NOT NULL REFERENCES dim_products_day84(product_id),
--     quantity            INTEGER NOT NULL CHECK (quantity > 0),
--     unit_price_at_order NUMERIC(10, 2) NOT NULL CHECK (unit_price_at_order > 0),
--     customer_id         INTEGER NOT NULL REFERENCES dim_customers_day84(customer_id),
--     order_date          DATE NOT NULL,
--     order_status        TEXT NOT NULL CHECK (order_status IN ('completed', 'pending', 'cancelled')),
--     line_amount         NUMERIC(12,2) NOT NULL CHECK (line_amount = quantity * unit_price_at_order),
--     PRIMARY KEY (order_id, item_id)
-- );

-- -- Quest 3.1: Загрузка Dimensions
-- INSERT INTO dim_customers_day84 (customer_id, customer_name, city)
-- SELECT
--     customer_id,
--     customer_name,
--     city
-- FROM src_customers_day84
-- RETURNING 
--     customer_id,
--     customer_name,
--     city;

-- INSERT INTO dim_products_day84 (product_id, product_name, category, catalog_price)
-- SELECT
--     product_id, 
--     product_name, 
--     category, 
--     catalog_price
-- FROM src_products_day84
-- RETURNING 
--     product_id, 
--     product_name, 
--     category, 
--     catalog_price;

-- -- Quest 3.2 — ETL: Loading the Fact Table
-- INSERT INTO fact_sales_day84 (order_id, item_id, product_id, quantity, unit_price_at_order, customer_id, order_date, order_status, line_amount)
-- SELECT
--     so.order_id,
--     soi.item_id,
--     soi.product_id, 
--     soi.quantity, 
--     soi.unit_price_at_order, 
--     so.customer_id, 
--     so.order_date, 
--     so.order_status, 
--     soi.quantity * soi.unit_price_at_order AS line_amount
-- FROM src_order_items_day84 AS soi
-- INNER JOIN src_orders_day84 AS so
-- ON so.order_id = soi.order_id
-- RETURNING
--     order_id, 
--     item_id, 
--     product_id, 
--     quantity, 
--     unit_price_at_order, 
--     customer_id, 
--     order_date, 
--     order_status, 
--     line_amount;

-- -- Quest 4.1 — Analytics: Revenue by Product Category
-- SELECT
--     dp.category,
--     SUM(fs.line_amount) AS total_revenue,
--     SUM(fs.quantity) AS total_units_sold
-- FROM fact_sales_day84 AS fs
-- INNER JOIN dim_products_day84 AS dp
-- ON fs.product_id = dp.product_id
-- WHERE fs.order_status = 'completed'
-- GROUP BY dp.category
-- ORDER BY total_revenue DESC;

-- -- Quest 4.2 — Revenue & Orders by Customer City
-- SELECT
--     dc.city,
--     SUM(fs.line_amount) AS total_revenue,
--     COUNT(DISTINCT fs.order_id) AS total_orders,
--     SUM(fs.quantity) AS total_units_sold
-- FROM fact_sales_day84 AS fs
-- INNER JOIN dim_customers_day84 AS dc
-- ON fs.customer_id = dc.customer_id
-- WHERE fs.order_status = 'completed'
-- GROUP BY dc.city
-- ORDER BY total_revenue DESC;

-- -- -- Quest 4.3 — Average Order Value (AOV)
-- WITH first_agre AS (
--     SELECT
--         dc.city,
--         SUM(fs.line_amount) AS total_revenue,
--         COUNT(DISTINCT fs.order_id) AS total_orders
--     FROM fact_sales_day84 AS fs
--     INNER JOIN dim_customers_day84 AS dc
--     ON fs.customer_id = dc.customer_id
--     WHERE fs.order_status = 'completed'
--     GROUP BY dc.city
-- )
-- SELECT
--     city,
--     total_revenue,
--     total_orders,
--     ROUND(total_revenue / total_orders, 2) AS avg_order_value
-- FROM first_agre
-- ORDER BY avg_order_value DESC;

-- -- Quest 4.4 — Меняем Grain для расчёта AOV
-- WITH orders_revenue AS (
--     SELECT
--         fs.order_id,
--         dc.city,
--         SUM(fs.line_amount) AS order_revenue
--     FROM fact_sales_day84 AS fs
--     INNER JOIN dim_customers_day84 AS dc
--     ON fs.customer_id = dc.customer_id
--     WHERE order_status = 'completed'
--     GROUP BY fs.order_id, dc.city
-- )
-- SELECT
--     city,
--     ROUND(AVG(order_revenue), 2) AS avg_order_value
-- FROM orders_revenue
-- GROUP BY city
-- ORDER BY avg_order_value DESC;

-- -- Quest 5.3 — Data Quality: проверяем Fact Table после ETL
-- SELECT  
--     soi.order_id,
--     soi.item_id,
--     soi.quantity * soi.unit_price_at_order AS expected_amount,
--     fs.line_amount AS actual_amount
-- FROM src_order_items_day84 AS soi
-- LEFT JOIN fact_sales_day84 AS fs
-- ON soi.order_id = fs.order_id
-- AND soi.item_id = fs.item_id
-- WHERE soi.quantity * soi.unit_price_at_order IS DISTINCT FROM fs.line_amount;

-- -- Quest 5.4 — Усиливаем Data Reconciliation
-- SELECT  
--     soi.order_id,
--     soi.item_id,
--     soi.quantity AS source_quantity,
--     fs.quantity AS target_quantity,
--     soi.unit_price_at_order AS source_price,
--     fs.unit_price_at_order AS target_price,
--     soi.quantity * soi.unit_price_at_order AS expected_amount,
--     fs.line_amount AS actual_amount
-- FROM src_order_items_day84 AS soi
-- LEFT JOIN fact_sales_day84 AS fs
-- ON soi.order_id = fs.order_id
-- AND soi.item_id = fs.item_id
-- WHERE soi.quantity * soi.unit_price_at_order IS DISTINCT FROM fs.line_amount
-- OR soi.quantity IS DISTINCT FROM fs.quantity
-- OR soi.unit_price_at_order IS DISTINCT FROM fs.unit_price_at_order;

-- Quest 5.5 — Cross-Table Reconciliation
SELECT 
    soi.order_id,
    soi.item_id,
    so.customer_id AS source_customer_id,
    fs.customer_id AS target_customer_id,
    so.order_status AS source_status,
    fs.order_status AS target_status
FROM src_order_items_day84 AS soi
LEFT JOIN src_orders_day84 AS so
ON soi.order_id = so.order_id
LEFT JOIN fact_sales_day84 AS fs
ON soi.order_id = fs.order_id
AND soi.item_id = fs.item_id
WHERE so.customer_id IS DISTINCT FROM fs.customer_id
OR so.order_status IS DISTINCT FROM fs.order_status
OR so.order_date IS DISTINCT FROM fs.order_date;