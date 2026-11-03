-- -- Day 75 — Stable Incremental Batch & Race Conditions.
-- -- Script from day74:
-- Quest 12 — Зафиксировать Incremental Batch
BEGIN;
-- создаем временную таблицу, чтобы зафиксировать в ней значения, пришедшие после ватермаки
CREATE TEMP TABLE batch_day75
ON COMMIT DROP 
AS
WITH current_watermark AS (
    SELECT
        last_ingested_at,
        last_event_id
    FROM pipeline_state_day74
    WHERE pipeline_name = 'orders_incremental'
),
incremental_batch AS (
    SELECT
        oe.event_id, 
        oe.order_id,
        oe.updated_at,
        oe.ingested_at,
        oe.amount,
        oe.status
    FROM orders_events_day74 AS oe
    CROSS JOIN current_watermark AS cw
    WHERE oe.ingested_at > cw.last_ingested_at
    OR (
        oe.ingested_at = cw.last_ingested_at
        AND oe.event_id > cw.last_event_id
    )
)

SELECT 
    event_id,
    order_id,
    updated_at,
    ingested_at,
    amount,
    status
FROM incremental_batch;

-- проверяем измненения батча
SELECT
    pg_backend_pid() AS session_id,
    COUNT(*) AS batch_size,
    ARRAY_AGG(event_id ORDER BY event_id) AS event_ids
FROM batch_day75;

SELECT
    last_ingested_at,
    last_event_id
FROM pipeline_state_day74
WHERE pipeline_name = 'orders_incremental';

-- Quest 13 — перевести UPSERT на чтение из batch_day75.
WITH valid_events AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at,
        ingested_at
    FROM batch_day75
    WHERE status IN ('completed', 'pending', 'cancelled')
        AND amount >= 0
),
ranked_valid_events AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at,
        ingested_at,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY updated_at DESC, event_id DESC
        ) AS valid_events_rank
    FROM valid_events
)

INSERT INTO orders_current_day74 (order_id, event_id, amount, status, updated_at)
SELECT
    order_id,
    event_id,
    amount,
    status,
    updated_at
FROM ranked_valid_events 
WHERE valid_events_rank = 1
ON CONFLICT (order_id) DO UPDATE SET
    event_id = EXCLUDED.event_id,
    amount = EXCLUDED.amount,
    status = EXCLUDED.status,
    updated_at = EXCLUDED.updated_at
WHERE EXCLUDED.updated_at > orders_current_day74.updated_at
    OR (
        EXCLUDED.updated_at = orders_current_day74.updated_at
        AND EXCLUDED.event_id > orders_current_day74.event_id
    )
    OR (
        EXCLUDED.updated_at = orders_current_day74.updated_at 
        AND EXCLUDED.event_id = orders_current_day74.event_id
        AND (
            EXCLUDED.status IS DISTINCT FROM orders_current_day74.status
            OR EXCLUDED.amount IS DISTINCT FROM orders_current_day74.amount
        )
    )
RETURNING order_id, event_id, amount, status, updated_at;

-- Quest 14 — Перевод Quarantine на Stable Batch
WITH invalid_events AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at,
        ingested_at,
        CASE
            WHEN amount IS NULL THEN 'AMOUNT_NULL'
            WHEN amount < 0 THEN 'NEGATIVE_AMOUNT'
            WHEN status NOT IN ('completed', 'pending', 'cancelled') THEN 'INVALID_STATUS'
            WHEN status IS NULL THEN 'STATUS_NULL'
        END AS reason
    FROM batch_day75
    WHERE status NOT IN ('completed', 'pending', 'cancelled')
        OR amount < 0
        OR amount IS NULL
        OR status IS NULL
)

INSERT INTO orders_quarantine_day74 (event_id, order_id, amount, status, updated_at, ingested_at, reason)
SELECT
    event_id,
    order_id,
    amount,
    status,
    updated_at,
    ingested_at,
    reason
FROM invalid_events
ON CONFLICT(event_id) DO NOTHING
RETURNING event_id, order_id, reason;

-- Quest 15 — Stable Watermark Update
WITH next_watermark AS (
    SELECT
        ingested_at AS next_ingested_at,
        event_id AS next_event_id
    FROM batch_day75
    ORDER BY ingested_at DESC, event_id DESC
    LIMIT 1
)

UPDATE pipeline_state_day74 AS ps
SET
    last_ingested_at = nw.next_ingested_at,
    last_event_id = nw.next_event_id
FROM next_watermark AS nw
WHERE ps.pipeline_name = 'orders_incremental'
RETURNING 
    ps.pipeline_name, 
    ps.last_ingested_at, 
    ps.last_event_id;

COMMIT;

-- Quest 17: INSERT REVIEW
-- INSERT INTO orders_events_day74 (event_id, order_id, amount, status, updated_at, ingested_at)
-- VALUES 
--     (4011, 709, 140.00, 'completed', '2026-11-01 11:50', '2026-11-01 12:00'),
--     (4012, 710, -5.00, 'pending', '2026-11-01 11:55', '2026-11-01 12:05')
