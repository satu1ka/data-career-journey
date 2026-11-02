-- -- Quest 1 — Найти новые события после Watermark
-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- )

-- SELECT
--     oe.event_id, 
--     oe.order_id,
--     oe.updated_at,
--     oe.ingested_at
-- FROM orders_events_day74 AS oe
-- CROSS JOIN current_watermark AS cw
-- WHERE oe.ingested_at > cw.last_ingested_at
-- OR (
--     oe.ingested_at = cw.last_ingested_at
--     AND oe.event_id > cw.last_event_id
-- )
-- ORDER BY oe.ingested_at, oe.event_id;

-- -- Quest 2 — Finding the Next Watermark
-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at
--     FROM orders_events_day74 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- )

-- SELECT
--     ingested_at AS next_ingested_at,
--     event_id AS next_event_id
-- FROM incremental_batch
-- ORDER BY ingested_at DESC, event_id DESC
-- LIMIT 1;

-- -- Quest 4: UPDATE Watermark
-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at
--     FROM orders_events_day74 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- ),
-- next_watermark AS (
--     SELECT
--         ingested_at AS next_ingested_at,
--         event_id AS next_event_id
--     FROM incremental_batch
--     ORDER BY ingested_at DESC, event_id DESC
--     LIMIT 1
-- )

-- UPDATE pipeline_state_day74 AS ps
-- SET
--     last_ingested_at = nw.next_ingested_at,
--     last_event_id = nw.next_event_id
-- FROM next_watermark AS nw
-- WHERE ps.pipeline_name = 'orders_incremental'
-- RETURNING 
--     ps.pipeline_name, 
--     ps.last_ingested_at, 
--     ps.last_event_id;

-- -- Quest 5 — Transaction & Rollback Safety
-- SELECT
--     last_ingested_at,
--     last_event_id
-- FROM pipeline_state_day74
-- WHERE pipeline_name = 'orders_incremental';

-- BEGIN;

-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at
--     FROM orders_events_day74 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- ),
-- next_watermark AS (
--     SELECT
--         ingested_at AS next_ingested_at,
--         event_id AS next_event_id
--     FROM incremental_batch
--     ORDER BY ingested_at DESC, event_id DESC
--     LIMIT 1
-- )

-- UPDATE pipeline_state_day74 AS ps
-- SET
--     last_ingested_at = nw.next_ingested_at,
--     last_event_id = nw.next_event_id
-- FROM next_watermark AS nw
-- WHERE ps.pipeline_name = 'orders_incremental'
-- RETURNING 
--     ps.pipeline_name, 
--     ps.last_ingested_at, 
--     ps.last_event_id;

-- ROLLBACK;

-- SELECT
--     last_ingested_at,
--     last_event_id
-- FROM pipeline_state_day74
-- WHERE pipeline_name = 'orders_incremental';

-- -- Quest 6: Incremental Batch Validation
-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at,
--         oe.amount,
--         oe.status
--     FROM orders_events_day74 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- ),
-- valid_events AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ingested_at
--     FROM incremental_batch
--     WHERE status IN ('completed', 'pending', 'cancelled')
--         AND amount >= 0
-- ),
-- invalid_events AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ingested_at,
--         CASE
--             WHEN amount IS NULL THEN 'AMOUNT_NULL'
--             WHEN amount < 0 THEN 'NEGATIVE_AMOUNT'
--             WHEN status NOT IN ('completed', 'pending', 'cancelled') THEN 'INVALID_STATUS'
--             WHEN status IS NULL THEN 'STATUS_NULL'
--         END AS reason
--     FROM incremental_batch
--     WHERE status NOT IN ('completed', 'pending', 'cancelled')
--         OR amount < 0
--         OR amount IS NULL
--         OR status IS NULL
-- )

-- SELECT
--     COUNT(ib.event_id) AS total_events,
--     COUNT(ve.event_id) AS valid_events,
--     COUNT(ie.event_id) AS invalid_events
-- FROM incremental_batch AS ib
-- LEFT JOIN valid_events AS ve
--     ON ib.event_id = ve.event_id
-- LEFT JOIN invalid_events AS ie
--     ON ib.event_id = ie.event_id;

-- -- Quest 7 — Incremental UPSERT into Current
-- BEGIN;

-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at,
--         oe.amount,
--         oe.status
--     FROM orders_events_day74 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- ),
-- valid_events AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ingested_at
--     FROM incremental_batch
--     WHERE status IN ('completed', 'pending', 'cancelled')
--         AND amount >= 0
-- ),
-- ranked_valid_events AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ingested_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS valid_events_rank
--     FROM valid_events
-- )

-- INSERT INTO orders_current_day74 (order_id, event_id, amount, status, updated_at)
-- SELECT
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at
-- FROM ranked_valid_events 
-- WHERE valid_events_rank = 1
-- ON CONFLICT (order_id) DO UPDATE SET
--     event_id = EXCLUDED.event_id,
--     amount = EXCLUDED.amount,
--     status = EXCLUDED.status,
--     updated_at = EXCLUDED.updated_at
-- WHERE EXCLUDED.updated_at > orders_current_day74.updated_at
--     OR (
--         EXCLUDED.updated_at = orders_current_day74.updated_at
--         AND EXCLUDED.event_id > orders_current_day74.event_id
--     )
--     OR (
--         EXCLUDED.updated_at = orders_current_day74.updated_at 
--         AND EXCLUDED.event_id = orders_current_day74.event_id
--         AND (
--             EXCLUDED.status IS DISTINCT FROM orders_current_day74.status
--             OR EXCLUDED.amount IS DISTINCT FROM orders_current_day74.amount
--         )
--     )
-- RETURNING order_id, event_id, amount, status, updated_at;

-- ROLLBACK;

-- -- Quest 8 — UPSERT INTO Quarantine
-- BEGIN;

-- WITH current_watermark AS (
--     SELECT
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day74
--     WHERE pipeline_name = 'orders_incremental'
-- ),
-- incremental_batch AS (
--     SELECT
--         oe.event_id, 
--         oe.order_id,
--         oe.updated_at,
--         oe.ingested_at,
--         oe.amount,
--         oe.status
--     FROM orders_events_day74 AS oe
--     CROSS JOIN current_watermark AS cw
--     WHERE oe.ingested_at > cw.last_ingested_at
--     OR (
--         oe.ingested_at = cw.last_ingested_at
--         AND oe.event_id > cw.last_event_id
--     )
-- ),
-- invalid_events AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ingested_at,
--         CASE
--             WHEN amount IS NULL THEN 'AMOUNT_NULL'
--             WHEN amount < 0 THEN 'NEGATIVE_AMOUNT'
--             WHEN status NOT IN ('completed', 'pending', 'cancelled') THEN 'INVALID_STATUS'
--             WHEN status IS NULL THEN 'STATUS_NULL'
--         END AS reason
--     FROM incremental_batch
--     WHERE status NOT IN ('completed', 'pending', 'cancelled')
--         OR amount < 0
--         OR amount IS NULL
--         OR status IS NULL
-- )

-- INSERT INTO orders_quarantine_day74 (event_id, order_id, amount, status, updated_at, ingested_at, reason)
-- SELECT
--     event_id,
--     order_id,
--     amount,
--     status,
--     updated_at,
--     ingested_at,
--     reason
-- FROM invalid_events
-- ON CONFLICT(event_id) DO NOTHING
-- RETURNING event_id, order_id, reason

-- ROLLBACK;

-- Quest 9 — Atomic Incremental Pipeline
BEGIN;

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
),
valid_events AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at,
        ingested_at
    FROM incremental_batch
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
),
invalid_events AS (
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
    FROM incremental_batch
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
        oe.ingested_at
    FROM orders_events_day74 AS oe
    CROSS JOIN current_watermark AS cw
    WHERE oe.ingested_at > cw.last_ingested_at
    OR (
        oe.ingested_at = cw.last_ingested_at
        AND oe.event_id > cw.last_event_id
    )
),
next_watermark AS (
    SELECT
        ingested_at AS next_ingested_at,
        event_id AS next_event_id
    FROM incremental_batch
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