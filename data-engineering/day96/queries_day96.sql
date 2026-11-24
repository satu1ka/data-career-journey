-- -- Day 96 — Incremental Loading: Multiple Batches, Failure Recovery & Data Quality
-- -- Quest 1.1 — Batch Discovery & Validation
-- -- Задание A — проверка текущего состояния
-- WITH source_orders_count AS (
--     SELECT 
--         COUNT(order_id) AS source_count
--     FROM source_orders_day95 
-- ),
-- fact_orders_count AS (
--     SELECT 
--         COUNT(order_id) AS fact_count
--     FROM fact_orders_day95
-- )

-- SELECT
--     so.source_count AS total_source_orders,
--     fo.fact_count AS total_fact_orders,
--     ps.last_successful_ingested_at AS current_watermark
-- FROM source_orders_count AS so
-- CROSS JOIN fact_orders_count AS fo
-- CROSS JOIN pipeline_state_day95 AS ps
-- WHERE ps.pipeline_name = 'orders_incremental';

-- -- Задание B — Second Batch Extraction
-- SELECT
--     order_id,
--     customer_id,
--     order_date, 
--     revenue, 
--     ingested_at
-- FROM source_orders_day95
-- WHERE ingested_at > (
--     SELECT 
--         last_successful_ingested_at
--     FROM pipeline_state_day95
--     WHERE pipeline_name = 'orders_incremental'
--     )
--     AND ingested_at <= TIMESTAMPTZ '2026-11-22 12:00:00+00'
-- ORDER BY ingested_at, order_id;

-- -- Quest 1.2 — Loading the Second Batch
-- BEGIN;

-- INSERT INTO fact_orders_day95 (
--     order_id, 
--     customer_id, 
--     order_date, 
--     revenue, 
--     ingested_at
-- )
-- SELECT
--     order_id,
--     customer_id,
--     order_date, 
--     revenue, 
--     ingested_at
-- FROM source_orders_day95 AS so
-- WHERE ingested_at > (
--     SELECT 
--         last_successful_ingested_at
--     FROM pipeline_state_day95
--     WHERE pipeline_name = 'orders_incremental'
--     )
--     AND ingested_at <= TIMESTAMPTZ '2026-11-22 12:00:00+00'
--     AND NOT EXISTS (
--         SELECT 1
--         FROM fact_orders_day95 AS fo
--         WHERE fo.order_id = so.order_id
--     );

-- UPDATE pipeline_state_day95
-- SET last_successful_ingested_at = TIMESTAMPTZ '2026-11-22 12:00:00+00'
-- WHERE pipeline_name = 'orders_incremental';

-- SELECT  
--     COUNT(*) AS orders_count_in_fact
-- FROM fact_orders_day95;

-- SELECT 
--     last_successful_ingested_at AS new_watermark
-- FROM pipeline_state_day95
-- WHERE pipeline_name = 'orders_incremental';

-- COMMIT;

-- -- Quest 2.1 — Подготовка аварийного Batch
-- BEGIN;

-- INSERT INTO fact_orders_day95 (
--     order_id, 
--     customer_id, 
--     order_date, 
--     revenue, 
--     ingested_at
-- )
-- SELECT
--     order_id,
--     customer_id,
--     order_date, 
--     revenue, 
--     ingested_at
-- FROM source_orders_day95 AS so
-- WHERE ingested_at > (
--     SELECT 
--         last_successful_ingested_at
--     FROM pipeline_state_day95
--     WHERE pipeline_name = 'orders_incremental'
--     )
--     AND ingested_at <= TIMESTAMPTZ '2026-11-23 10:00:00+00'
--     AND NOT EXISTS (
--         SELECT 1
--         FROM fact_orders_day95 AS fo
--         WHERE fo.order_id = so.order_id
--     );

-- UPDATE pipeline_state_day95
-- SET last_successful_ingested_at = TIMESTAMPTZ '2026-11-23 10:00:00+00'
-- WHERE pipeline_name = 'orders_incremental';

-- SELECT  
--     COUNT(*) AS orders_count_in_fact
-- FROM fact_orders_day95;

-- SELECT 
--     last_successful_ingested_at AS new_watermark
-- FROM pipeline_state_day95
-- WHERE pipeline_name = 'orders_incremental';

-- -- тут мы сознательно пытаемся вставить некорректную строку
-- INSERT INTO fact_orders_day95 (
--     order_id, 
--     customer_id, 
--     order_date, 
--     revenue, 
--     ingested_at
-- )
-- VALUES (
--     1001,
--     10,
--     '2026-11-18', 
--     120, 
--     '2026-11-20 08:30:00+00'
-- );

-- ROLLBACK;

-- -- Проверки после роллбека
-- SELECT  
--     COUNT(*) AS orders_count_in_fact
-- FROM fact_orders_day95;

-- SELECT 
--     last_successful_ingested_at AS new_watermark
-- FROM pipeline_state_day95
-- WHERE pipeline_name = 'orders_incremental';

-- -- Quest 2.2 — Failure Recovery: Successful Retry
-- BEGIN;

-- INSERT INTO fact_orders_day95 (
--     order_id, 
--     customer_id, 
--     order_date, 
--     revenue, 
--     ingested_at
-- )
-- SELECT
--     order_id,
--     customer_id,
--     order_date, 
--     revenue, 
--     ingested_at
-- FROM source_orders_day95 AS so
-- WHERE ingested_at > (
--     SELECT 
--         last_successful_ingested_at
--     FROM pipeline_state_day95
--     WHERE pipeline_name = 'orders_incremental'
--     )
--     AND ingested_at <= TIMESTAMPTZ '2026-11-23 10:00:00+00'
--     AND NOT EXISTS (
--         SELECT 1
--         FROM fact_orders_day95 AS fo
--         WHERE fo.order_id = so.order_id
--     );

-- UPDATE pipeline_state_day95
-- SET last_successful_ingested_at = TIMESTAMPTZ '2026-11-23 10:00:00+00'
-- WHERE pipeline_name = 'orders_incremental';

-- SELECT  
--     COUNT(*) AS orders_count_in_fact
-- FROM fact_orders_day95;

-- SELECT 
--     last_successful_ingested_at AS new_watermark
-- FROM pipeline_state_day95
-- WHERE pipeline_name = 'orders_incremental';

-- SELECT 
--     *
-- FROM fact_orders_day95
-- WHERE order_id IN (1011, 1012);

-- COMMIT;

-- -- Quest 3.1 — Диагностика без изменения данных
-- -- Запрос A — обычная Incremental Extraction
-- SELECT 
--     *
-- FROM source_orders_day95
-- WHERE ingested_at <= TIMESTAMPTZ '2026-11-23 12:00:00+00'
--     AND ingested_at > (
--         SELECT last_successful_ingested_at
--         FROM pipeline_state_day95
--         WHERE pipeline_name = 'orders_incremental'
--     );

-- -- Запрос B — Data Reconciliation
-- SELECT
--     so.order_id,
--     so.ingested_at,
--     so.revenue
-- FROM source_orders_day95 AS so
-- LEFT JOIN fact_orders_day95 AS fa
--     ON so.order_id = fa.order_id
-- WHERE fa.order_id IS NULL;

-- Quest 3.2 — Lookback Window: как защититься от запоздавших записей?
SELECT 
    order_id,
    ingested_at,
    revenue
FROM source_orders_day95 AS so
WHERE ingested_at <= TIMESTAMPTZ '2026-11-23 12:00:00+00'
    AND ingested_at > (
        SELECT last_successful_ingested_at
        FROM pipeline_state_day95
        WHERE pipeline_name = 'orders_incremental'
    )
    - 
    INTERVAL '60 minutes'
    AND NOT EXISTS (
        SELECT 1
        FROM fact_orders_day95 AS fa
        WHERE fa.order_id = so.order_id
    )
ORDER BY ingested_at, order_id;