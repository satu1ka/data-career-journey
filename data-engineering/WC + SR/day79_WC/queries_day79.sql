-- Day 79
-- Saturday Weekly Challenge

-- The Missing Parcels Incident
-- Правила бизнеса:
-- - Допустимые статусы: registered, in_transit, delivered, returned.
-- - weight_kg должен быть строго больше 0.
-- - Актуальная версия посылки определяется по (occurred_at, event_id).
-- - Watermark определяется по (ingested_at, event_id).
-- - Lookback Window для инцидента — 60 минут.

-- -- Quest 1 — Incident Investigation
-- WITH current_watermark AS (
--     SELECT 
--         last_ingested_at,
--         last_event_id
--     FROM pipeline_state_day79
--     WHERE pipeline_name = 'parcel_tracking'
-- )

-- SELECT
--     pe.event_id,
--     pe.parcel_id,
--     pe.ingested_at,
--     CASE
--         WHEN pe.ingested_at > cw.last_ingested_at
--             OR pe.ingested_at = cw.last_ingested_at
--             AND pe.event_id > cw.last_event_id THEN 'AHEAD'
--         WHEN pe.ingested_at >= cw.last_ingested_at - INTERVAL '60 minutes' THEN 'LATE_IN_WINDOW'
--         ELSE 'LATE_OUTSIDE_WINDOW'
--     END AS incident_category
-- FROM parcel_events_day79 AS pe
-- LEFT JOIN parcel_processed_day79 AS pp
-- ON pe.event_id = pp.event_id
-- CROSS JOIN current_watermark AS cw
-- WHERE pp.event_id IS NULL
-- ORDER BY pe.ingested_at, pe.event_id

-- Quest 2 — Pipeline Repair: Architecture Decision
BEGIN;

CREATE TEMP TABLE parcel_batch_day79
ON COMMIT DROP
AS
WITH current_watermark AS (
    SELECT 
        last_ingested_at,
        last_event_id
    FROM pipeline_state_day79
    WHERE pipeline_name = 'parcel_tracking'
),
parcel_tracking AS (
    SELECT
        pe.event_id,
        pe.parcel_id,
        pe.status,
        pe.weight_kg,
        pe.occurred_at,
        pe.ingested_at
    FROM parcel_events_day79 AS pe
    CROSS JOIN current_watermark AS cw
    WHERE pe.ingested_at >= cw.last_ingested_at - INTERVAL '60 minutes'
)

SELECT 
    event_id,
    parcel_id,
    status,
    weight_kg,
    occurred_at,
    ingested_at
FROM parcel_tracking;

-- -- диагностический селект:
-- SELECT
--     pb.event_id,
--     pb.parcel_id,
--     pb.status,
--     pb.weight_kg,
--     CASE
--         WHEN pb.status IN ('registered', 'in_transit', 'delivered', 'returned') AND pb.weight_kg > 0  THEN 'ACCEPTED'
--         ELSE 'REJECTED'
--     END AS validation_result
--     FROM parcel_batch_day79 AS pb
--     LEFT JOIN parcel_processed_day79 AS pp
--     ON pb.event_id = pp.event_id
--     WHERE pp.event_id IS NULL;

-- Вставка значений в карантин
INSERT INTO parcel_quarantine_day79 (event_id, parcel_id, status, weight_kg, occurred_at, ingested_at, reason)
SELECT 
    pb.event_id, 
    pb.parcel_id, 
    pb.status, 
    pb.weight_kg, 
    pb.occurred_at, 
    pb.ingested_at, 
    CASE
        WHEN pb.status NOT IN ('registered', 'in_transit', 'delivered', 'returned') OR pb.status IS NULL THEN 'INVALID_STATUS'
        WHEN pb.weight_kg <= 0 THEN 'INVALID_WEIGHT'
        WHEN pb.weight_kg IS NULL THEN 'MISSING_WEIGHT'
    END AS reason
    FROM parcel_batch_day79 AS pb
    LEFT JOIN parcel_processed_day79 AS pp
    ON pb.event_id = pp.event_id
    WHERE pp.event_id IS NULL
        AND (
            pb.status NOT IN ('registered', 'in_transit', 'delivered', 'returned')
            OR pb.status IS NULL
            OR pb.weight_kg <= 0
            OR pb.weight_kg IS NULL
        )
ON CONFLICT (event_id) DO NOTHING
RETURNING 
    event_id, 
    parcel_id, 
    status, 
    weight_kg, 
    occurred_at, 
    ingested_at, 
    reason;

-- Quest 2.4 — Processed Registry
WITH validation_parcels AS (
    SELECT
        event_id,
        parcel_id,
        CASE
            WHEN status IN ('registered', 'in_transit', 'delivered', 'returned')
                AND weight_kg > 0 THEN 'ACCEPTED'
            ELSE 'REJECTED'
        END AS outcome,
        ingested_at
    FROM parcel_batch_day79
)

INSERT INTO parcel_processed_day79 (event_id, parcel_id, outcome, ingested_at)
SELECT
    vp.event_id,
    vp.parcel_id,
    vp.outcome,
    vp.ingested_at
FROM validation_parcels AS vp
LEFT JOIN parcel_processed_day79 AS pp
ON vp.event_id = pp.event_id
WHERE pp.event_id IS NULL
ON CONFLICT (event_id) DO NOTHING
RETURNING 
    event_id, 
    parcel_id,
    outcome,
    ingested_at;

-- Quest 2.5 — Conditional UPSERT в Current
WITH correct_parcels AS (
    SELECT
        parcel_id,
        event_id,
        status,
        weight_kg,
        occurred_at
    FROM parcel_batch_day79
    WHERE status IN ('registered', 'in_transit', 'delivered', 'returned')
        AND weight_kg > 0
),
last_correct_parcel AS (
    SELECT
        parcel_id,
        event_id,
        status,
        weight_kg,
        occurred_at,
        ROW_NUMBER() OVER (
            PARTITION BY parcel_id
            ORDER BY occurred_at DESC, event_id DESC
        ) AS last_correct
    FROM correct_parcels
)

INSERT INTO parcel_current_day79 (parcel_id, event_id, status, weight_kg, occurred_at)
SELECT
    parcel_id,
    event_id,
    status,
    weight_kg,
    occurred_at
FROM last_correct_parcel
WHERE last_correct = 1
ON CONFLICT (parcel_id) DO UPDATE SET
    event_id = EXCLUDED.event_id,
    status = EXCLUDED.status,
    weight_kg = EXCLUDED.weight_kg,
    occurred_at = EXCLUDED.occurred_at
WHERE EXCLUDED.occurred_at > parcel_current_day79.occurred_at
    OR (
        EXCLUDED.occurred_at = parcel_current_day79.occurred_at
        AND EXCLUDED.event_id > parcel_current_day79.event_id
    )
RETURNING parcel_id, event_id, weight_kg, status, occurred_at;

-- Quest 2.6 — Watermark Update
WITH next_watermark AS (
    SELECT
        ingested_at AS new_ingested_at,
        event_id AS new_event_id
    FROM parcel_batch_day79
    ORDER BY new_ingested_at DESC, new_event_id DESC
    LIMIT 1
)

UPDATE pipeline_state_day79 AS ps
SET
    last_ingested_at = nw.new_ingested_at,
    last_event_id = nw.new_event_id
FROM next_watermark AS nw
WHERE ps.pipeline_name = 'parcel_tracking'
AND (nw.new_ingested_at, nw.new_event_id)
    > (ps.last_ingested_at, ps.last_event_id)
RETURNING
    ps.pipeline_name,
    ps.last_ingested_at,
    ps.last_event_id;

-- Задание 3.1 — Recovery Detection
CREATE TEMP TABLE parcel_recovery_day79
ON COMMIT DROP
AS
WITH current_watermark AS (
    SELECT
        last_ingested_at,
        last_event_id
    FROM pipeline_state_day79
    WHERE pipeline_name = 'parcel_tracking'
)
SELECT
    pe.event_id, 
    pe.parcel_id, 
    pe.status, 
    pe.weight_kg, 
    pe.occurred_at, 
    pe.ingested_at
FROM parcel_events_day79 AS pe
CROSS JOIN current_watermark AS cw
LEFT JOIN parcel_processed_day79 AS pp
ON pe.event_id = pp.event_id
WHERE pp.event_id IS NULL
AND pe.ingested_at < cw.last_ingested_at - INTERVAL '60 minutes';

WITH validation_parcels AS (
    SELECT
        event_id,
        parcel_id,
        CASE
            WHEN status IN ('registered', 'in_transit', 'delivered', 'returned')
                AND weight_kg > 0 THEN 'ACCEPTED'
            ELSE 'REJECTED'
        END AS outcome,
        ingested_at
    FROM parcel_recovery_day79
)

INSERT INTO parcel_processed_day79 (event_id, parcel_id, outcome, ingested_at)
SELECT
    vp.event_id,
    vp.parcel_id,
    vp.outcome,
    vp.ingested_at
FROM validation_parcels AS vp
LEFT JOIN parcel_processed_day79 AS pp
ON vp.event_id = pp.event_id
WHERE pp.event_id IS NULL
ON CONFLICT (event_id) DO NOTHING
RETURNING 
    event_id, 
    parcel_id,
    outcome,
    ingested_at;

-- Quest 3.4 — Recovery Current UPSERT
WITH correct_parcels AS (
    SELECT
        parcel_id,
        event_id,
        status,
        weight_kg,
        occurred_at
    FROM parcel_recovery_day79
    WHERE status IN ('registered', 'in_transit', 'delivered', 'returned')
        AND weight_kg > 0
),
last_correct_parcel AS (
    SELECT
        parcel_id,
        event_id,
        status,
        weight_kg,
        occurred_at,
        ROW_NUMBER() OVER (
            PARTITION BY parcel_id
            ORDER BY occurred_at DESC, event_id DESC
        ) AS last_correct
    FROM correct_parcels
)

INSERT INTO parcel_current_day79 (parcel_id, event_id, status, weight_kg, occurred_at)
SELECT
    parcel_id,
    event_id,
    status,
    weight_kg,
    occurred_at
FROM last_correct_parcel
WHERE last_correct = 1
ON CONFLICT (parcel_id) DO UPDATE SET
    event_id = EXCLUDED.event_id,
    status = EXCLUDED.status,
    weight_kg = EXCLUDED.weight_kg,
    occurred_at = EXCLUDED.occurred_at
WHERE EXCLUDED.occurred_at > parcel_current_day79.occurred_at
    OR (
        EXCLUDED.occurred_at = parcel_current_day79.occurred_at
        AND EXCLUDED.event_id > parcel_current_day79.event_id
    )
RETURNING parcel_id, event_id, weight_kg, status, occurred_at;

-- -- Задание 4.1 — Post-load Verification - диагностические селекты
-- SELECT *
-- FROM parcel_processed_day79
-- WHERE event_id = 5097;

-- SELECT * 
-- FROM parcel_current_day79
-- WHERE parcel_id = 809;

-- SELECT
--     last_ingested_at,
--     last_event_id
-- FROM pipeline_state_day79
-- WHERE pipeline_name = 'parcel_tracking';

COMMIT;

SELECT 
    COUNT(*) AS unprocessed_events
FROM parcel_events_day79  AS pe
LEFT JOIN parcel_processed_day79 AS pp
ON pe.event_id = pp.event_id
WHERE pp.event_id IS NULL;
