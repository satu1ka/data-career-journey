-- SCD Type 2: Incremental Loading & Change Detection
-- -- Quest 1.1
-- SELECT
--     sc.customer_id,
--     sc.customer_name,
--     sc.city AS source_city,
--     dc.city AS current_city,
--     CASE
--         WHEN dc.city = sc.city THEN 'UNCHANGED'
--         WHEN dc.city <> sc.city THEN 'CHANGED'
--         WHEN dc.customer_sk IS NULL THEN 'NEW'
--     END AS change_type
-- FROM stg_customers_day90 AS sc
-- LEFT JOIN dim_customers_scd_day90 AS dc
-- ON dc.customer_id = sc.customer_id
-- AND dc.valid_to IS NULL;

-- -- Quest 1.3 — Detecting Reactivated Customers
-- SELECT
--     sc.customer_id,
--     sc.customer_name,
--     dc.customer_sk,
--     sc.city AS source_city,
--     dc.city AS current_city,
--     CASE
--         WHEN dc.customer_sk IS NULL 
--             AND EXISTS (
--                 SELECT 1
--                 FROM dim_customers_scd_day90 AS history
--                 WHERE history.customer_id = sc.customer_id
--             )
--         THEN 'REACTIVATED'
--         WHEN dc.city = sc.city THEN 'UNCHANGED'
--         WHEN dc.city <> sc.city THEN 'CHANGED'
--         WHEN dc.customer_sk IS NULL THEN 'NEW'
--     END AS change_type
-- FROM stg_customers_day90 AS sc
-- LEFT JOIN dim_customers_scd_day90 AS dc
-- ON dc.customer_id = sc.customer_id
-- AND dc.valid_to IS NULL;

-- -- Quest 2.1 — Preparing an Incremental Change Set
BEGIN;

CREATE TEMP TABLE day90_change_set AS
SELECT
    sc.customer_id,
    sc.customer_name,
    sc.city AS source_city,
    dc.customer_sk AS current_sk,
    CASE
        WHEN dc.customer_sk IS NULL 
            AND EXISTS (
                SELECT 1
                FROM dim_customers_scd_day90 AS history
                WHERE history.customer_id = sc.customer_id
            )
        THEN 'REACTIVATED'
        WHEN dc.city = sc.city THEN 'UNCHANGED'
        WHEN dc.city <> sc.city THEN 'CHANGED'
        WHEN dc.customer_sk IS NULL THEN 'NEW'
    END AS change_type
FROM stg_customers_day90 AS sc
LEFT JOIN dim_customers_scd_day90 AS dc
ON dc.customer_id = sc.customer_id
AND dc.valid_to IS NULL;

-- -- Quest 2.2 — Closing Current SCD Version
UPDATE dim_customers_scd_day90 AS dc
SET valid_to = DATE '2026-05-01'
FROM day90_change_set AS cs
WHERE cs.change_type = 'CHANGED'
    AND dc.customer_sk = cs.current_sk
    AND dc.valid_to IS NULL;

SELECT * 
FROM dim_customers_scd_day90
WHERE customer_id = 20
ORDER BY valid_from;

-- Quest 2.3 — Creating a New SCD Type 2 Version
INSERT INTO dim_customers_scd_day90 (customer_sk, customer_id, customer_name, city, valid_from, valid_to)
SELECT
    203,
    cs.customer_id,
    cs.customer_name,
    cs.source_city AS city,
    DATE '2026-05-01' AS valid_from,
    NULL AS valid_to
FROM day90_change_set AS cs
WHERE cs.change_type = 'CHANGED'
    AND NOT EXISTS (
    SELECT 1
    FROM dim_customers_scd_day90 AS dc
    WHERE dc.valid_to IS NULL 
        AND dc.customer_id = cs.customer_id
);

SELECT * 
FROM dim_customers_scd_day90
WHERE customer_id = 20
ORDER BY valid_from;

COMMIT;

SELECT NOT EXISTS (
    SELECT 1
    FROM dim_customers_scd_day90
    WHERE customer_id = 20
      AND valid_to IS NULL
) AS can_insert;