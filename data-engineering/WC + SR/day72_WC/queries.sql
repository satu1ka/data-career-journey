-- -- Weekly Challenge 
-- -- Quest 1: Valid Events & Latest State
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day72
--     WHERE amount >= 0
--         AND status IN ('pending', 'completed', 'cancelled') 
--         -- можно 2 нижних убрать, т.к. они автоматически исключатся 2 верхними
--         AND amount IS NOT NULL
--         AND status IS NOT NULL
-- ),
-- last_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS order_rank
--     FROM correct_orders
-- )

-- SELECT 
--     event_id,
--     order_id,
--     amount,
--     status,
--     updated_at
-- FROM last_orders
-- WHERE order_rank = 1
-- ORDER BY order_id;

-- -- Quest 2: Quarantine & Idempotency
-- WITH incorrect_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day72
--     WHERE amount < 0
--         OR status NOT IN ('pending', 'completed', 'cancelled')
--         OR status IS NULL
--         OR amount IS NULL
-- )

-- INSERT INTO orders_quarantine_day72 (event_id, order_id, reason)
-- SELECT
--     event_id,
--     order_id,
--     CASE
--         WHEN amount IS NULL THEN 'AMOUNT_NULL'
--         WHEN amount < 0 THEN 'NEGATIVE_AMOUNT'
--         WHEN status IS NULL THEN 'STATUS_NULL'
--         WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'INVALID_STATUS'
--     END AS reason
-- FROM incorrect_orders
-- ON CONFLICT (event_id) DO NOTHING
-- RETURNING event_id, order_id, reason, quarantined_at;

-- -- -- Quest 3: Data Reconciliation Audit
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day72
--     WHERE amount >= 0
--         AND status IN ('pending', 'completed', 'cancelled') 
--         -- можно 2 нижних убрать, т.к. они автоматически исключатся 2 верхними
--         AND amount IS NOT NULL
--         AND status IS NOT NULL
-- ),
-- last_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS order_rank
--     FROM correct_orders
-- )

-- SELECT 
--     lo.order_id,
--     oc.event_id AS actual_event_id,
--     lo.event_id AS expected_event_id,
--     oc.updated_at AS actual_updated_at,
--     lo.updated_at AS expected_updated_at,
--     CASE    
--         WHEN oc.order_id IS NULL THEN 'MISSING'
--         WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--         WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--         WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--         WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--         WHEN oc.updated_at = lo.updated_at 
--             AND oc.event_id = lo.event_id 
--             AND (oc.amount IS DISTINCT FROM lo.amount OR oc.status IS DISTINCT FROM lo.status) THEN 'DATA_MISMATCH'
--         ELSE 'MATCH'
--     END AS reconciliation_status
-- FROM last_orders AS lo
-- LEFT JOIN orders_current_day72 AS oc
-- ON lo.order_id = oc.order_id
-- WHERE lo.order_rank = 1
-- ORDER BY lo.order_id;

-- Quest 4: Conditional UPSERT & Idempotency
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day72
--     WHERE amount >= 0
--         AND status IN ('pending', 'completed', 'cancelled') 
--         -- можно 2 нижних убрать, т.к. они автоматически исключатся 2 верхними
--         AND amount IS NOT NULL
--         AND status IS NOT NULL
-- ),
-- last_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS order_rank
--     FROM correct_orders
-- )

-- INSERT INTO orders_current_day72 (order_id, event_id, amount, status, updated_at)
-- SELECT
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at
-- FROM last_orders
-- WHERE order_rank = 1
-- ON CONFLICT (order_id) DO UPDATE SET
--     event_id = EXCLUDED.event_id,
--     amount = EXCLUDED.amount,
--     status = EXCLUDED.status,
--     updated_at = EXCLUDED.updated_at
-- WHERE EXCLUDED.updated_at > orders_current_day72.updated_at
-- OR (
--     EXCLUDED.updated_at = orders_current_day72.updated_at 
--     AND EXCLUDED.event_id > orders_current_day72.event_id
--     )
-- OR (
--     EXCLUDED.updated_at = orders_current_day72.updated_at 
--     AND EXCLUDED.event_id = orders_current_day72.event_id
--     AND (
--         EXCLUDED.status IS DISTINCT FROM orders_current_day72.status
--         OR EXCLUDED.amount IS DISTINCT FROM orders_current_day72.amount
--     )
-- )
-- RETURNING order_id, event_id, amount, status, updated_at;

-- -- Quest 5 — Data Quality Gate & Pipeline Verification
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day72
--     WHERE amount >= 0
--         AND status IN ('pending', 'completed', 'cancelled') 
--         -- можно 2 нижних убрать, т.к. они автоматически исключатся 2 верхними
--         AND amount IS NOT NULL
--         AND status IS NOT NULL
-- ),
-- last_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS order_rank
--     FROM correct_orders
-- ),
-- reconciliation_orders AS (
--     SELECT 
--         lo.order_id,
--         oc.event_id AS actual_event_id,
--         lo.event_id AS expected_event_id,
--         oc.updated_at AS actual_updated_at,
--         lo.updated_at AS expected_updated_at,
--         CASE    
--             WHEN oc.order_id IS NULL THEN 'MISSING'
--             WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--             WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at 
--                 AND oc.event_id = lo.event_id 
--                 AND (oc.amount IS DISTINCT FROM lo.amount OR oc.status IS DISTINCT FROM lo.status) THEN 'DATA_MISMATCH'
--             ELSE 'MATCH'
--         END AS reconciliation_status
--     FROM last_orders AS lo
--     LEFT JOIN orders_current_day72 AS oc
--     ON lo.order_id = oc.order_id
--     WHERE lo.order_rank = 1
-- ),
-- quality_orders AS (
--     SELECT
--         COUNT(*) AS total_orders,
--         COALESCE(SUM(
--             CASE 
--                 WHEN reconciliation_status IN ('MISSING', 'OUTDATED', 'DATA_MISMATCH') THEN 1
--                 ELSE 0
--             END
--         ), 0) AS failed_orders
--     FROM reconciliation_orders
-- ),
-- staging_quality AS (
--     SELECT  
--         COUNT(*) AS total_events,
--         COUNT(*) FILTER (
--             WHERE amount < 0 
--             OR status NOT IN ('pending', 'completed', 'cancelled') 
--             OR status IS NULL 
--             OR amount IS NULL
--         ) AS invalid_events,
--         COUNT(*) FILTER (
--             WHERE amount < 0 
--             OR status NOT IN ('pending', 'completed', 'cancelled') 
--             OR status IS NULL 
--             OR amount IS NULL
--         ) * 100.0
--         /
--         NULLIF(COUNT(*), 0) AS invalid_rate
--     FROM orders_staging_day72
-- )

-- SELECT
--     sq.total_events,
--     sq.invalid_events,
--     sq.invalid_rate,
--     qo.total_orders,
--     qo.failed_orders,
--     CASE
--         WHEN sq.total_events = 0 
--             OR qo.total_orders = 0
--             OR qo.failed_orders > 0
--             OR sq.invalid_rate > 5 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_gate_status
-- FROM staging_quality AS sq
-- CROSS JOIN quality_orders AS qo;

-- Quest 6: Post-Load Data Assertions
WITH missing_invalid AS (
    SELECT
        COUNT(*) AS missing_invalid_events
    FROM orders_staging_day72 AS os
    LEFT JOIN orders_quarantine_day72 AS oq
    ON os.event_id = oq.event_id
    WHERE
        (
            os.amount < 0
            OR os.status NOT IN ('pending', 'completed', 'cancelled')
            OR os.status IS NULL
            OR os.amount IS NULL
        )
        AND oq.event_id IS NULL
),
wrongly_quarantined AS (
    SELECT
        COUNT(*) AS wrongly_quarantined_events
    FROM orders_staging_day72 AS os
    LEFT JOIN orders_quarantine_day72 AS oq
    ON os.event_id = oq.event_id
    WHERE
        (
            os.amount >= 0
            AND os.status IN ('pending', 'completed', 'cancelled')
        )
        AND oq.event_id IS NOT NULL
)

SELECT
    mi.missing_invalid_events,
    wq.wrongly_quarantined_events,
    CASE
        WHEN mi.missing_invalid_events = 0 
        AND wq.wrongly_quarantined_events = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS assertion_status
FROM missing_invalid AS mi
CROSS JOIN wrongly_quarantined AS wq;
