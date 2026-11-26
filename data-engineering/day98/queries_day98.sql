-- Day 98 — Data Quality & Pipeline Reliability
-- -- создаем VIEW для переиспользования:
-- CREATE OR REPLACE VIEW day98_dq_gate_v3 AS
-- WITH missing_orders AS (
--     SELECT
--         COUNT(so.order_id) AS missing_orders
--     FROM source_orders_day95 AS so
--     LEFT JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE fo.order_id IS NULL
--     AND so.ingested_at <= (
--         SELECT 
--             last_successful_ingested_at
--         FROM pipeline_state_day95
--         WHERE pipeline_name = 'orders_incremental'
--         )
-- ),
-- revenue_mismatches AS (
--     SELECT
--         COUNT(fo.order_id) AS revenue_mismatches
--     FROM fact_orders_day95 AS fo
--     INNER JOIN source_orders_day95 AS so
--         ON fo.order_id = so.order_id
--     WHERE fo.revenue IS DISTINCT FROM so.revenue
-- ),
-- pending_orders AS (
--     SELECT
--         COUNT(so.order_id) AS pending_orders
--     FROM source_orders_day95 AS so
--     LEFT JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE so.ingested_at > (
--             SELECT 
--                 last_successful_ingested_at
--             FROM pipeline_state_day95
--             WHERE pipeline_name = 'orders_incremental'
--             )
--         AND fo.order_id IS NULL
-- ),
-- fact_only_orders AS (
--     SELECT
--         COUNT(fo.order_id) AS fact_only_orders
--     FROM fact_orders_day95 AS fo
--     LEFT JOIN source_orders_day95 AS so
--         ON fo.order_id = so.order_id
--     WHERE so.order_id IS NULL
-- ),
-- attribute_mismatches AS (
--     SELECT
--         COUNT(DISTINCT so.order_id) AS attribute_mismatches
--     FROM source_orders_day95 AS so
--     INNER JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE so.customer_id IS DISTINCT FROM fo.customer_id
--         OR so.order_date IS DISTINCT FROM fo.order_date
-- )
-- SELECT 
--     mo.missing_orders,
--     rm.revenue_mismatches,
--     po.pending_orders,
--     foo.fact_only_orders,
--     am.attribute_mismatches,
--     CASE
--         WHEN mo.missing_orders > 0 
--             OR rm.revenue_mismatches > 0 
--             OR foo.fact_only_orders > 0 
--             OR am.attribute_mismatches > 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_status
-- FROM missing_orders AS mo
-- CROSS JOIN revenue_mismatches AS rm
-- CROSS JOIN pending_orders AS po
-- CROSS JOIN fact_only_orders AS foo
-- CROSS JOIN attribute_mismatches AS am;

-- -- Quest 1 — Silent Data Corruption
-- SELECT
--     so.order_id,
--     so.customer_id AS source_customer_id,
--     fo.customer_id AS fact_customer_id,
--     so.order_date AS source_order_date,
--     fo.order_date AS fact_order_date
-- FROM source_orders_day95 AS so
-- INNER JOIN fact_orders_day95 AS fo
--     ON so.order_id = fo.order_id
-- WHERE so.customer_id IS DISTINCT FROM fo.customer_id
--     OR so.order_date IS DISTINCT FROM fo.order_date
-- ORDER BY so.order_id;

-- -- Quest 2 — Data Quality Gate v3: Attribute Consistency
-- Перенесли это полотно выше в создание View
-- WITH missing_orders AS (
--     SELECT
--         COUNT(so.order_id) AS missing_orders
--     FROM source_orders_day95 AS so
--     LEFT JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE fo.order_id IS NULL
--     AND so.ingested_at <= (
--         SELECT 
--             last_successful_ingested_at
--         FROM pipeline_state_day95
--         WHERE pipeline_name = 'orders_incremental'
--         )
-- ),
-- revenue_mismatches AS (
--     SELECT
--         COUNT(fo.order_id) AS revenue_mismatches
--     FROM fact_orders_day95 AS fo
--     INNER JOIN source_orders_day95 AS so
--         ON fo.order_id = so.order_id
--     WHERE fo.revenue IS DISTINCT FROM so.revenue
-- ),
-- pending_orders AS (
--     SELECT
--         COUNT(so.order_id) AS pending_orders
--     FROM source_orders_day95 AS so
--     LEFT JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE so.ingested_at > (
--             SELECT 
--                 last_successful_ingested_at
--             FROM pipeline_state_day95
--             WHERE pipeline_name = 'orders_incremental'
--             )
--         AND fo.order_id IS NULL
-- ),
-- fact_only_orders AS (
--     SELECT
--         COUNT(fo.order_id) AS fact_only_orders
--     FROM fact_orders_day95 AS fo
--     LEFT JOIN source_orders_day95 AS so
--         ON fo.order_id = so.order_id
--     WHERE so.order_id IS NULL
-- ),
-- attribute_mismatches AS (
--     SELECT
--         COUNT(DISTINCT so.order_id) AS attribute_mismatches
--     FROM source_orders_day95 AS so
--     INNER JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE so.customer_id IS DISTINCT FROM fo.customer_id
--         OR so.order_date IS DISTINCT FROM fo.order_date
-- )
-- SELECT 
--     mo.missing_orders,
--     rm.revenue_mismatches,
--     po.pending_orders,
--     foo.fact_only_orders,
--     am.attribute_mismatches,
--     CASE
--         WHEN mo.missing_orders > 0 
--             OR rm.revenue_mismatches > 0 
--             OR foo.fact_only_orders > 0 
--             OR am.attribute_mismatches > 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_status
-- FROM missing_orders AS mo
-- CROSS JOIN revenue_mismatches AS rm
-- CROSS JOIN pending_orders AS po
-- CROSS JOIN fact_only_orders AS foo
-- CROSS JOIN attribute_mismatches AS am;

-- -- Quest 3 — Negative Testing: Multiple Attribute Corruption
-- BEGIN;

-- UPDATE fact_orders_day95
-- SET
--     customer_id = 30,
--     order_date = '2026-11-21 08:20:00+00'
-- WHERE order_id = 1002;

-- SELECT * FROM day98_dq_gate_v3;

-- ROLLBACK;

-- SELECT * FROM day98_dq_gate_v3;

-- -- Quest 4 — Missing Data Incident
-- BEGIN;

-- DELETE FROM fact_orders_day95
-- WHERE order_id = 1013;

-- SELECT * FROM day98_dq_gate_v3;

-- ROLLBACK;

-- SELECT * FROM day98_dq_gate_v3;

-- Quest 5 — Control Plane Failure: пропавший Watermark
BEGIN;

DELETE FROM pipeline_state_day95
WHERE pipeline_name = 'orders_incremental';

SELECT * FROM day98_dq_gate_v3;

ROLLBACK;

SELECT * FROM day98_dq_gate_v3;