-- Slowly Changing Dimensions (SCD)
-- -- Quest 4.1: создаём исторические версии
-- INSERT INTO dim_customers_scd_day88 (customer_sk, customer_id, customer_name, city, valid_from, valid_to) 
-- VALUES
--     (101, 10, 'Anna', 'Berlin',  '2026-01-01', '2026-03-01'),
--     (102, 10, 'Anna', 'Hamburg',  '2026-03-01', NULL)
-- RETURNING customer_sk, customer_id, customer_name, city, valid_from, valid_to;

-- -- Quest 4.2 — SCD Type 2 Update: переезд в Munich
-- BEGIN;

-- UPDATE dim_customers_scd_day88
-- SET valid_to = '2026-04-01'
-- WHERE customer_id = 10
--     AND valid_to IS NULL
-- RETURNING customer_sk, customer_id, customer_name, city, valid_from, valid_to;

-- INSERT INTO dim_customers_scd_day88 (customer_sk, customer_id, customer_name, city, valid_from, valid_to) 
-- VALUES
--     (103, 10, 'Anna', 'Munich',  '2026-04-01', NULL)
-- RETURNING customer_sk, customer_id, customer_name, city, valid_from, valid_to;

-- COMMIT;

-- SELECT
--     customer_sk,
--     customer_id,
--     city,
--     valid_from,
--     valid_to
-- FROM dim_customers_scd_day88
-- WHERE customer_id = 10
-- ORDER BY valid_from;

-- SELECT 
--     COUNT(*) AS current_version
-- FROM dim_customers_scd_day88
-- WHERE valid_to IS NULL 
--     AND customer_id = 10;

-- -- Quest 5: Temporal JOIN
-- SELECT
--     fo.order_id,
--     fo.order_date,
--     fo.customer_id,
--     dc.customer_sk,
--     dc.city,
--     fo.revenue
-- FROM fact_orders_day88 AS fo
-- INNER JOIN dim_customers_scd_day88 AS dc
-- ON fo.customer_id = dc.customer_id
--     AND fo.order_date >= dc.valid_from
--     AND (fo.order_date < dc.valid_to
--     OR dc.valid_to IS NULL)
-- ORDER BY fo.order_date;

-- -- Quest 5.2 — Historical Revenue by City
-- SELECT
--     dc.city,
--     SUM(fo.revenue) AS total_revenue,
--     COUNT(*) AS total_orders
-- FROM fact_orders_day88 AS fo
-- INNER JOIN dim_customers_scd_day88 AS dc
-- ON fo.customer_id = dc.customer_id
--     AND fo.order_date >= dc.valid_from
--     AND (fo.order_date < dc.valid_to
--     OR dc.valid_to IS NULL)
-- GROUP BY dc.city
-- ORDER BY total_revenue DESC;

-- Quest 5.3 — Проверяем надёжность Temporal JOIN
SELECT 
    fo.order_id,
    COUNT(dc.customer_sk) AS matching_versions
FROM fact_orders_day88 AS fo
LEFT JOIN dim_customers_scd_day88 AS dc
ON fo.customer_id = dc.customer_id
    AND fo.order_date >= dc.valid_from
    AND (fo.order_date < dc.valid_to
    OR dc.valid_to IS NULL)
GROUP BY order_id
HAVING COUNT(dc.customer_sk) <> 1;