-- Day 99 — PostgreSQL VIEW: Mechanics, Design & Data Quality
-- Quest 1 — Is a VIEW Really Dynamic?
-- CREATE VIEW day99_high_value_orders AS
-- SELECT 
--     order_id,
--     customer_id,
--     revenue,
--     order_date
-- FROM fact_orders_day95
-- WHERE revenue >= 100;

-- SELECT *
-- FROM day99_high_value_orders;

-- BEGIN;

-- UPDATE fact_orders_day95
-- SET revenue = 300
-- WHERE order_id = 1013;

-- SELECT *
-- FROM day99_high_value_orders;

-- ROLLBACK;

-- SELECT *
-- FROM day99_high_value_orders;

-- -- Quest 2 — Changing Business Requirements
-- CREATE OR REPLACE VIEW day99_high_value_orders AS
-- SELECT
--     order_id,
--     customer_id,
--     revenue,
--     order_date
-- FROM fact_orders_day95
-- WHERE revenue >= 150;

-- SELECT * 
-- FROM day99_high_value_orders;

-- CREATE OR REPLACE VIEW day99_high_value_orders AS
-- SELECT
--     order_id,
--     customer_id,
--     revenue,
--     order_date
-- FROM fact_orders_day95
-- WHERE revenue >= 100;

-- SELECT * 
-- FROM day99_high_value_orders;

-- -- Quest 3 — VIEW Dependencies & Safe Deletion
-- -- CREATE VIEW day99_training_base_v AS
-- -- SELECT
-- --     order_id,
-- --     customer_id,
-- --     revenue
-- -- FROM fact_orders_day95;

-- -- CREATE VIEW day99_training_summary_v AS
-- -- SELECT
-- --     customer_id,
-- --     SUM(revenue) AS total_revenue
-- -- FROM day99_training_base_v
-- -- GROUP BY customer_id;

-- SELECT * 
-- FROM day99_training_base_v;

-- SELECT *
-- FROM day99_training_summary_v;

-- DROP VIEW day99_training_base_v;

-- -- Quest 4 — Safe VIEW Evolution
-- -- CREATE OR REPLACE VIEW day99_training_base_v AS
-- -- SELECT
-- --     order_id,
-- --     customer_id,
-- --     revenue,
-- --     order_date
-- -- FROM fact_orders_day95;

-- SELECT * 
-- FROM day99_training_base_v;

-- SELECT *
-- FROM day99_training_summary_v;

-- -- тест изменения названия колонки вью у которого есть в зависимости другое вью
-- CREATE OR REPLACE VIEW day99_training_base_v AS
-- SELECT
--     order_id,
--     customer_id,
--     revenue AS amount,
--     order_date
-- FROM fact_orders_day95;

-- -- Quest 5 — ALTER VIEW: безопасное переименование
-- BEGIN;

-- ALTER VIEW day99_training_base_v 
-- RENAME COLUMN revenue TO amount;

-- SELECT *
-- FROM day99_training_base_v;

-- SELECT *
-- FROM day99_training_summary_v;

-- ROLLBACK;

-- SELECT *
-- FROM day99_training_base_v;

-- SELECT *
-- FROM day99_training_summary_v;

-- -- Quest 6 — Breaking the Client Contract
-- BEGIN;

-- ALTER VIEW day99_training_base_v 
-- RENAME COLUMN revenue TO amount;

-- SELECT
--     revenue
-- FROM day99_training_base_v;

-- ROLLBACK;

-- SELECT revenue
-- FROM day99_training_base_v
-- LIMIT 3;

-- -- Quest 7 — Backward-Compatible VIEW Migration
-- BEGIN;

-- CREATE OR REPLACE VIEW day99_training_base_v AS
-- SELECT
--     order_id,
--     customer_id,
--     revenue,
--     order_date,
--     revenue AS amount
-- FROM fact_orders_day95;

-- SELECT *
-- FROM day99_training_summary_v;

-- CREATE VIEW day99_training_summary_v2 AS
-- SELECT
--     customer_id,
--     SUM(amount) AS total_amount
-- FROM day99_training_base_v
-- GROUP BY customer_id;

-- SELECT * 
-- FROM day99_training_summary_v2;

-- SELECT
--     order_id
-- FROM day99_training_base_v 
-- WHERE revenue IS DISTINCT FROM amount;

-- WITH fact_orders_count AS (
--     SELECT
--         COUNT(*) AS fact_orders_count
--     FROM fact_orders_day95
-- ),
-- training_base_orders_count AS (
--     SELECT
--         COUNT(*) AS training_base_orders_count
--     FROM day99_training_base_v
-- )

-- SELECT 
--     fo.fact_orders_count - tb.training_base_orders_count AS orders_difference
-- FROM fact_orders_count AS fo
-- CROSS JOIN training_base_orders_count AS tb;

-- SELECT 
--     order_id
-- FROM day99_training_base_v
-- GROUP BY order_id
-- HAVING COUNT(order_id) > 1;

-- COMMIT;

-- -- Quest 8 — Data Quality Gate v4: Missing Watermark
-- CREATE OR REPLACE VIEW day99_dq_gate_v4 AS
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
-- ),
-- watermark_status AS (
--     SELECT 
--         CASE
--             WHEN COUNT(*) = 1 THEN 'OK'
--             ELSE 'MISSING'
--         END AS watermark_status
--     FROM pipeline_state_day95
--     WHERE pipeline_name = 'orders_incremental'
--         AND last_successful_ingested_at IS NOT NULL
-- )
-- SELECT 
--     mo.missing_orders,
--     rm.revenue_mismatches,
--     po.pending_orders,
--     foo.fact_only_orders,
--     am.attribute_mismatches,
--     ws.watermark_status,
--     CASE
--         WHEN mo.missing_orders > 0 
--             OR rm.revenue_mismatches > 0 
--             OR foo.fact_only_orders > 0 
--             OR am.attribute_mismatches > 0 
--             OR ws.watermark_status = 'MISSING' THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_status
-- FROM missing_orders AS mo
-- CROSS JOIN revenue_mismatches AS rm
-- CROSS JOIN pending_orders AS po
-- CROSS JOIN fact_only_orders AS foo
-- CROSS JOIN attribute_mismatches AS am
-- CROSS JOIN watermark_status AS ws;

BEGIN;

SELECT *
FROM day99_dq_gate_v4;

DELETE FROM pipeline_state_day95
WHERE pipeline_name = 'orders_incremental';

SELECT *
FROM day99_dq_gate_v4;

ROLLBACK;

SELECT *
FROM day99_dq_gate_v4;