-- Day 77 — Late Commits & Watermark Reliability
-- Quest 2 — Шаг 6: выбираем Incremental Batch
-- WITH current_watermark AS (
--     SELECT
--         last_event_id,
--         last_ingested_at
--     FROM pipeline_state_day77
--     WHERE pipeline_name = 'orders_late_commit_lab'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at,
--         oe.amount,
--         oe.status
--     FROM orders_events_day77 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- )

-- SELECT
--     event_id,
--     order_id,
--     ingested_at
-- FROM incremental_batch;

-- -- Шаг 7 — Обрабатываем 4016 и продвигаем Watermark
-- BEGIN;

-- CREATE TEMP TABLE batch_day77
-- ON COMMIT DROP
-- AS
-- WITH current_watermark AS (
--     SELECT
--         last_event_id,
--         last_ingested_at
--     FROM pipeline_state_day77
--     WHERE pipeline_name = 'orders_late_commit_lab'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at,
--         oe.amount,
--         oe.status
--     FROM orders_events_day77 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- )
-- -- обязательный селект, чтобы заполнить временную таблицу
-- SELECT 
--     event_id,
--     order_id,
--     updated_at,
--     ingested_at,
--     amount,
--     status
-- FROM incremental_batch;

-- INSERT INTO orders_processed_day77 (event_id, order_id, ingested_at)
-- SELECT 
--     event_id,
--     order_id,
--     ingested_at
-- FROM batch_day77
-- ON CONFLICT (event_id) DO NOTHING
-- RETURNING event_id, order_id, ingested_at;

-- WITH next_watermark AS (
--     SELECT
--         ingested_at AS next_ingested_at,
--         event_id AS next_event_id
--     FROM batch_day77
--     ORDER BY ingested_at DESC, event_id DESC
--     LIMIT 1
-- )

-- UPDATE pipeline_state_day77 AS ps
-- SET
--     last_ingested_at = nw.next_ingested_at,
--     last_event_id = nw.next_event_id
-- FROM next_watermark AS nw
-- WHERE ps.pipeline_name = 'orders_late_commit_lab'
-- RETURNING 
--     ps.pipeline_name, 
--     ps.last_ingested_at, 
--     ps.last_event_id;

-- COMMIT;

-- -- Quest 2 — Шаг 8: запоздалый COMMIT
-- -- проверяем, отсутствующиее событие
-- SELECT
--     oe.event_id,
--     oe.order_id,
--     oe.ingested_at
-- FROM orders_events_day77 AS oe
-- LEFT JOIN orders_processed_day77 AS op
-- ON oe.event_id = op.event_id
-- WHERE op.event_id IS NULL;

-- -- Quest 3 — Lookback Window - ищем пропущенное событие
-- WITH current_watermark AS (
--     SELECT
--         last_event_id,
--         last_ingested_at
--     FROM pipeline_state_day77
--     WHERE pipeline_name = 'orders_late_commit_lab'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.ingested_at
--     FROM orders_events_day77 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at >= cw.last_ingested_at - INTERVAL '10 minutes'
-- )

-- SELECT 
--     event_id,
--     order_id,
--     ingested_at
-- FROM incremental_batch
-- ORDER BY ingested_at, event_id;

-- -- Quest 4 — Recovering Missing Events
-- WITH current_watermark AS (
--     SELECT
--         last_event_id,
--         last_ingested_at
--     FROM pipeline_state_day77
--     WHERE pipeline_name = 'orders_late_commit_lab'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.ingested_at
--     FROM orders_events_day77 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at >= cw.last_ingested_at - INTERVAL '10 minutes'
-- )

-- INSERT INTO orders_processed_day77 (event_id, order_id, ingested_at)
-- SELECT 
--     event_id,
--     order_id,
--     ingested_at
-- FROM incremental_batch
-- ON CONFLICT (event_id) DO NOTHING
-- RETURNING event_id, order_id, ingested_at;

-- Quest 7 — Reconciliation-based Recovery
WITH missing_rows AS (
    SELECT
        oe.event_id,
        oe.order_id,
        oe.ingested_at
    FROM orders_events_day77 AS oe
    LEFT JOIN orders_processed_day77 AS op
    ON oe.event_id = op.event_id
    WHERE op.event_id IS NULL
)

INSERT INTO orders_processed_day77 (event_id, order_id, ingested_at)
SELECT 
    event_id,
    order_id,
    ingested_at
FROM missing_rows
ON CONFLICT (event_id) DO NOTHING
RETURNING
    event_id, order_id, ingested_at;