-- -- Quest 1 — Finding Missing & Outdated Orders
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day70
--     WHERE amount >= 0
--     AND status IN ('completed', 'pending', 'cancelled')
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
--         ) AS last_event
--     FROM correct_orders
-- )

-- SELECT 
--     lo.order_id,
--     lo.amount,
--     lo.status,
--     lo.updated_at,
--     lo.event_id AS expected_event_id,
--     oc.event_id AS actual_event_id
-- FROM last_orders AS lo
-- LEFT JOIN orders_current_day70 as oc
-- ON lo.order_id = oc.order_id
-- WHERE lo.last_event = 1
-- AND (
--     oc.order_id IS NULL
--     OR lo.event_id IS DISTINCT FROM oc.event_id
--     );

-- -- Quest 2
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day70
--     WHERE amount >= 0
--     AND status IN ('completed', 'pending', 'cancelled')
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
--         ) AS last_event
--     FROM correct_orders
-- )

-- SELECT 
--     lo.order_id,
--     lo.event_id AS expected_event_id,
--     oc.event_id AS actual_event_id,
--     lo.updated_at AS expected_updated_at,
--     oc.updated_at AS actual_updated_at,
--     CASE
--         WHEN oc.order_id IS NULL THEN 'MISSING'
--         WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--         WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--         WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--         WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--         ELSE 'MATCH'
--     END AS reconciliation_status
-- FROM last_orders AS lo
-- LEFT JOIN orders_current_day70 as oc
-- ON lo.order_id = oc.order_id
-- WHERE lo.last_event = 1
-- ORDER BY order_id;

-- -- Quest 3 — Reconciliation Metrics
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day70
--     WHERE amount >= 0
--     AND status IN ('completed', 'pending', 'cancelled')
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
--         ) AS last_event
--     FROM correct_orders
-- ),
-- reconciliation_orders AS (
--     SELECT 
--         lo.order_id,
--         lo.event_id AS expected_event_id,
--         oc.event_id AS actual_event_id,
--         lo.updated_at AS expected_updated_at,
--         oc.updated_at AS actual_updated_at,
--         CASE
--             WHEN oc.order_id IS NULL THEN 'MISSING'
--             WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--             WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--             ELSE 'MATCH'
--         END AS reconciliation_status
--     FROM last_orders AS lo
--     LEFT JOIN orders_current_day70 as oc
--     ON lo.order_id = oc.order_id
--     WHERE lo.last_event = 1
-- )

-- SELECT
--     reconciliation_status,
--     COUNT(reconciliation_status) AS orders_count
-- FROM reconciliation_orders
-- GROUP BY reconciliation_status
-- ORDER BY reconciliation_status;

-- -- Quest 4 — Data Consistency Check
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day70
--     WHERE amount >= 0
--     AND status IN ('completed', 'pending', 'cancelled')
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
--         ) AS last_event
--     FROM correct_orders
-- ),
-- reconciliation_orders AS (
--     SELECT 
--         lo.order_id,
--         lo.event_id AS expected_event_id,
--         oc.event_id AS actual_event_id,
--         lo.updated_at AS expected_updated_at,
--         oc.updated_at AS actual_updated_at,
--         CASE
--             WHEN oc.order_id IS NULL THEN 'MISSING'
--             WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--             WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at 
--                 AND oc.event_id = lo.event_id 
--                 AND (
--                     oc.amount IS DISTINCT FROM lo.amount 
--                     OR oc.status IS DISTINCT FROM lo.status
--                     ) THEN 'DATA_MISMATCH'
--             ELSE 'MATCH'
--         END AS reconciliation_status
--     FROM last_orders AS lo
--     LEFT JOIN orders_current_day70 as oc
--     ON lo.order_id = oc.order_id
--     WHERE lo.last_event = 1
-- )

-- SELECT
--     reconciliation_status,
--     COUNT(reconciliation_status) AS orders_count
-- FROM reconciliation_orders
-- GROUP BY reconciliation_status
-- ORDER BY reconciliation_status;

-- -- Quest 5 — Data Quality Gate
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day70
--     WHERE amount >= 0
--     AND status IN ('completed', 'pending', 'cancelled')
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
--         ) AS last_event
--     FROM correct_orders
-- ),
-- reconciliation_orders AS (
--     SELECT 
--         lo.order_id,
--         lo.event_id AS expected_event_id,
--         oc.event_id AS actual_event_id,
--         lo.updated_at AS expected_updated_at,
--         oc.updated_at AS actual_updated_at,
--         CASE
--             WHEN oc.order_id IS NULL THEN 'MISSING'
--             WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--             WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at 
--                 AND oc.event_id = lo.event_id 
--                 AND (
--                     oc.amount IS DISTINCT FROM lo.amount 
--                     OR oc.status IS DISTINCT FROM lo.status
--                     ) THEN 'DATA_MISMATCH'
--             ELSE 'MATCH'
--         END AS reconciliation_status
--     FROM last_orders AS lo
--     LEFT JOIN orders_current_day70 as oc
--     ON lo.order_id = oc.order_id
--     WHERE lo.last_event = 1
-- ),
-- quality_orders AS (
--     SELECT
--     COUNT(*) AS total_orders,
--     COALESCE(SUM(
        -- CASE 
        --     WHEN reconciliation_status IN ('MISSING', 'OUTDATED', 'DATA_MISMATCH') THEN 1
        --     ELSE 0
        -- END
--     ), 0)AS failed_orders
-- FROM reconciliation_orders
-- )

-- -- Quest 6
-- SELECT
--     total_orders,
--     failed_orders,
--     CASE
--         WHEN failed_orders > 0 OR total_orders = 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_gate_status
-- FROM quality_orders;

-- -- Quest 7: обнаруживаем скрытые ошибки
-- SELECT
--     COUNT(*) AS total_events,
--     COUNT(*) FILTER (
--         WHERE amount < 0 
--         OR status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL 
--         OR amount IS NULL
--     ) AS invalid_events
-- FROM orders_staging_day70;

-- -- Quest 8
-- WITH correct_orders AS (
--     SELECT
--         event_id,
--         order_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day70
--     WHERE amount >= 0
--     AND status IN ('completed', 'pending', 'cancelled')
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
--         ) AS last_event
--     FROM correct_orders
-- ),
-- reconciliation_orders AS (
--     SELECT 
--         lo.order_id,
--         lo.event_id AS expected_event_id,
--         oc.event_id AS actual_event_id,
--         lo.updated_at AS expected_updated_at,
--         oc.updated_at AS actual_updated_at,
--         CASE
--             WHEN oc.order_id IS NULL THEN 'MISSING'
--             WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
--             WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
--             WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
--             WHEN oc.updated_at = lo.updated_at 
--                 AND oc.event_id = lo.event_id 
--                 AND (
--                     oc.amount IS DISTINCT FROM lo.amount 
--                     OR oc.status IS DISTINCT FROM lo.status
--                     ) THEN 'DATA_MISMATCH'
--             ELSE 'MATCH'
--         END AS reconciliation_status
--     FROM last_orders AS lo
--     LEFT JOIN orders_current_day70 as oc
--     ON lo.order_id = oc.order_id
--     WHERE lo.last_event = 1
-- ),
-- quality_orders AS (
--     SELECT
--         COUNT(*) AS total_orders,
--         COALESCE(SUM(
--             CASE 
--                 WHEN reconciliation_status IN ('MISSING', 'OUTDATED', 'DATA_MISMATCH') THEN 1
--                 ELSE 0
--             END
--         ), 0)AS failed_orders
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
--         ) AS invalid_events
--     FROM orders_staging_day70
-- )

-- SELECT
--     sq.total_events,
--     sq.invalid_events,
--     qo.total_orders,
--     qo.failed_orders,
--     CASE
--         WHEN qo.failed_orders > 0 
--             OR qo.total_orders = 0 
--             OR sq.total_events = 0
--             OR sq.invalid_events > 0
--             THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_gate_status
-- FROM staging_quality AS sq
-- CROSS JOIN quality_orders AS qo;

-- Quest 9
WITH correct_orders AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at
    FROM orders_staging_day70
    WHERE amount >= 0
    AND status IN ('completed', 'pending', 'cancelled')
),
last_orders AS (
    SELECT
        event_id,
        order_id,
        amount,
        status,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY updated_at DESC, event_id DESC
        ) AS last_event
    FROM correct_orders
),
reconciliation_orders AS (
    SELECT 
        lo.order_id,
        lo.event_id AS expected_event_id,
        oc.event_id AS actual_event_id,
        lo.updated_at AS expected_updated_at,
        oc.updated_at AS actual_updated_at,
        CASE
            WHEN oc.order_id IS NULL THEN 'MISSING'
            WHEN oc.updated_at < lo.updated_at THEN 'OUTDATED'
            WHEN oc.updated_at > lo.updated_at THEN 'TARGET_NEWER'
            WHEN oc.updated_at = lo.updated_at AND oc.event_id < lo.event_id THEN 'OUTDATED'
            WHEN oc.updated_at = lo.updated_at AND oc.event_id > lo.event_id THEN 'TARGET_NEWER'
            WHEN oc.updated_at = lo.updated_at 
                AND oc.event_id = lo.event_id 
                AND (
                    oc.amount IS DISTINCT FROM lo.amount 
                    OR oc.status IS DISTINCT FROM lo.status
                    ) THEN 'DATA_MISMATCH'
            ELSE 'MATCH'
        END AS reconciliation_status
    FROM last_orders AS lo
    LEFT JOIN orders_current_day70 as oc
    ON lo.order_id = oc.order_id
    WHERE lo.last_event = 1
),
quality_orders AS (
    SELECT
        COUNT(*) AS total_orders,
        COALESCE(SUM(
            CASE 
                WHEN reconciliation_status IN ('MISSING', 'OUTDATED', 'DATA_MISMATCH') THEN 1
                ELSE 0
            END
        ), 0)AS failed_orders
    FROM reconciliation_orders
),
staging_quality AS (
    SELECT
        COUNT(*) AS total_events,
        COUNT(*) FILTER (
            WHERE amount < 0 
            OR status NOT IN ('pending', 'completed', 'cancelled') 
            OR status IS NULL 
            OR amount IS NULL
        ) AS invalid_events
    FROM orders_staging_day70
)

SELECT
    sq.total_events,
    sq.invalid_events,
    qo.total_orders,
    qo.failed_orders,
    sq.invalid_events * 100.0
    / 
    NULLIF(sq.total_events, 0)  AS invalid_rate,
    CASE
        WHEN qo.failed_orders > 0 
            OR qo.total_orders = 0 
            OR sq.total_events = 0
            OR (sq.invalid_events * 100.0
                / 
                NULLIF(sq.total_events, 0)) > 5
            THEN 'FAIL'
        ELSE 'PASS'
    END AS quality_gate_status
FROM staging_quality AS sq
CROSS JOIN quality_orders AS qo;
