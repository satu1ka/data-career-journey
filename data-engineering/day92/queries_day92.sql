-- -- Quest 1.1 — Change Detection
-- SELECT
--     sc.customer_id,
--     sc.customer_name,
--     sc.city AS source_city,
--     dc.customer_sk AS current_sk,
--     CASE
--         WHEN dc.customer_sk IS NULL 
--             AND EXISTS (
--                 SELECT 1
--                 FROM dim_customers_scd_day92 AS history
--                 WHERE history.customer_id = sc.customer_id
--             )
--         THEN 'REACTIVATED'
--         WHEN (dc.city = sc.city AND dc.customer_name = sc.customer_name) THEN 'UNCHANGED'
--         WHEN (dc.city <> sc.city OR dc.customer_name <> sc.customer_name) THEN 'CHANGED'
--         WHEN dc.customer_sk IS NULL THEN 'NEW'
--     END AS change_type
-- FROM stg_customers_day92 AS sc
-- LEFT JOIN dim_customers_scd_day92 AS dc
-- ON sc.customer_id = dc.customer_id
-- AND dc.valid_to IS NULL;

-- -- Quest 1.2 — Создание Change Set
-- DROP TABLE IF EXISTS day92_change_set;

-- CREATE TABLE day92_change_set AS
-- SELECT
--     sc.customer_id,
--     sc.customer_name,
--     sc.city AS source_city,
--     dc.customer_sk AS current_sk,
--     CASE
--         WHEN dc.customer_sk IS NULL 
--             AND EXISTS (
--                 SELECT 1
--                 FROM dim_customers_scd_day92 AS history
--                 WHERE history.customer_id = sc.customer_id
--             )
--         THEN 'REACTIVATED'
--         WHEN (dc.city = sc.city AND dc.customer_name = sc.customer_name) THEN 'UNCHANGED'
--         WHEN (dc.city <> sc.city OR dc.customer_name <> sc.customer_name) THEN 'CHANGED'
--         WHEN dc.customer_sk IS NULL THEN 'NEW'
--     END AS change_type
-- FROM stg_customers_day92 AS sc
-- LEFT JOIN dim_customers_scd_day92 AS dc
-- ON sc.customer_id = dc.customer_id
-- AND dc.valid_to IS NULL;

-- SELECT * FROM day92_change_set;

-- -- Quest 2.3 — Transactional SCD Type 2 Load
-- BEGIN;
-- -- Quest 2.1 — Closing Changed Versions
-- UPDATE dim_customers_scd_day92 AS dc
-- SET valid_to = DATE '2026-05-01'
-- FROM day92_change_set AS cs
-- WHERE cs.change_type = 'CHANGED'
--     AND dc.customer_sk = cs.current_sk
--     AND dc.valid_to IS NULL;

-- -- Quest 2.2 — INSERT новых исторических версий
-- INSERT INTO dim_customers_scd_day92 (customer_id, customer_name, city, valid_from, valid_to)
-- SELECT
--     cs.customer_id,
--     cs.customer_name,
--     cs.source_city AS city,
--     DATE '2026-05-01' AS valid_from,
--     NULL AS valid_to
-- FROM day92_change_set AS cs
-- WHERE cs.change_type IN ('CHANGED', 'NEW', 'REACTIVATED')
-- AND NOT EXISTS (
--     SELECT 1
--     FROM dim_customers_scd_day92 AS dc
--     WHERE dc.valid_to IS NULL 
--         AND dc.customer_id = cs.customer_id
-- );

-- -- Verification SELECT
-- SELECT  
--     *
-- FROM dim_customers_scd_day92
-- ORDER BY customer_id, valid_from;

-- COMMIT;

-- Quest 2.4 — Data Quality Verification
SELECT
    COUNT(customer_sk) AS total_versions,
    COUNT(*) FILTER (
        WHERE valid_to IS NULL
    ) AS active_versions,
    COUNT(*) FILTER (
        WHERE valid_to IS NOT NULL
    ) AS closed_versions
FROM dim_customers_scd_day92;

SELECT 
    customer_id,
    COUNT(*) AS active_versions_count
FROM dim_customers_scd_day92
WHERE valid_to IS NULL 
GROUP BY customer_id
HAVING COUNT(*) > 1;
