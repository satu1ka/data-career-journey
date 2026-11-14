-- Analytical Data Modeling & SQL: Real-World Case

-- -- Quest 1 — The Sales Dashboard Problem
-- fact_sales_day84
-- dim_customers_day84
-- dim_products_day84

-- -- Quest 2 — Пишем SQL для отчёта
-- SELECT
--     fs.order_date AS report_date,
--     dc.city,
--     dm.category,
--     SUM(fs.line_amount) AS total_revenue,
--     COUNT(DISTINCT fs.order_id) AS total_orders,
--     SUM(fs.quantity) AS total_units
-- FROM fact_sales_day84 AS fs
-- INNER JOIN dim_customers_day84 AS dc
-- ON fs.customer_id = dc.customer_id  
-- INNER JOIN dim_products_day84 AS dm
-- ON fs.product_id = dm.product_id
-- WHERE fs.order_status = 'completed'
-- GROUP BY report_date, dc.city, dm.category
-- ORDER BY report_date, dc.city, dm.category;

-- -- Quest 3 — AOV: определяем бизнес-метрику
-- -- Quest 3.1 — Реализуем Category Revenue per Order
-- SELECT
--     fs.order_date AS report_date,
--     dc.city,
--     dm.category,
--     SUM(fs.line_amount) AS total_revenue,
--     COUNT(DISTINCT fs.order_id) AS total_orders,
--     SUM(fs.quantity) AS total_units,
--     ROUND(SUM(fs.line_amount) / COUNT(DISTINCT fs.order_id), 2) AS avg_category_revenue_per_order
-- FROM fact_sales_day84 AS fs
-- INNER JOIN dim_customers_day84 AS dc
-- ON fs.customer_id = dc.customer_id  
-- INNER JOIN dim_products_day84 AS dm
-- ON fs.product_id = dm.product_id
-- WHERE fs.order_status = 'completed'
-- GROUP BY report_date, dc.city, dm.category
-- ORDER BY report_date, dc.city, dm.category;

-- -- Quest 4 — Daily Totals: проблема агрегации отчёта
-- SELECT
--     fs.order_date AS report_date,
--     dc.city,
--     SUM(fs.line_amount) AS total_revenue,
--     COUNT(DISTINCT fs.order_id) AS total_orders,
--     SUM(fs.quantity) AS total_units,
--     ROUND(SUM(fs.line_amount) / COUNT(DISTINCT fs.order_id), 2) AS aov
-- FROM fact_sales_day84 AS fs
-- INNER JOIN dim_customers_day84 AS dc
-- ON fs.customer_id = dc.customer_id  
-- WHERE fs.order_status = 'completed'
-- GROUP BY report_date, dc.city
-- ORDER BY report_date, dc.city;

-- Quest 5: The Double-Counted Orders Incident
WITH actual_orders AS (
    SELECT  
        fs.order_date,
        dc.city,
        COUNT(DISTINCT fs.order_id) AS actual_orders_count
    FROM fact_sales_day84 AS fs
    INNER JOIN dim_customers_day84 as dc
    ON fs.customer_id = dc.customer_id
    WHERE fs.order_status = 'completed'
    GROUP BY fs.order_date, dc.city
),
orders_by_category AS (
    SELECT
        fs.order_date,
        dc.city,
        dp.category,
        COUNT(DISTINCT fs.order_id) AS orders_count_by_category
    FROM fact_sales_day84 AS fs
    INNER JOIN dim_customers_day84 as dc
    ON fs.customer_id = dc.customer_id
    INNER JOIN dim_products_day84 AS dp
    ON fs.product_id = dp.product_id
    WHERE fs.order_status = 'completed'
    GROUP BY fs.order_date, dc.city, dp.category
),
orders_by_category_metrics AS (
    SELECT
        order_date,
        city,
        SUM(orders_count_by_category) AS summed_category_orders
    FROM orders_by_category 
    GROUP BY order_date, city
)

SELECT 
    obcm.order_date AS report_date,
    obcm.city,
    ao.actual_orders_count AS actual_orders,
    obcm.summed_category_orders,
    obcm.summed_category_orders - ao.actual_orders_count AS difference
FROM orders_by_category_metrics AS obcm
INNER JOIN actual_orders AS ao
ON (obcm.order_date = ao.order_date
    AND obcm.city = ao.city)
WHERE obcm.summed_category_orders - ao.actual_orders_count <> 0;