-- -- Quest 1 — Data Quality Validation
-- SELECT
--     event_id,
--     order_id,
--     amount,
--     status
-- FROM orders_staging_day69
-- WHERE amount IS NULL
-- OR amount < 0
-- OR (
--     status NOT IN ('pending', 'completed', 'cancelled') 
--     OR status IS NULL
-- );

-- -- Quest 2 — Valid Data Filtering
-- SELECT
--     event_id,
--     order_id,
--     amount,
--     status,
--     updated_at
-- FROM orders_staging_day69
-- WHERE amount >= 0
-- AND status IN ('pending', 'completed', 'cancelled')
-- ORDER BY event_id;

-- -- Quest 3 — Data Quality + Deduplication
-- WITH correct_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day69
--     WHERE amount >= 0
--     AND status IN ('pending', 'completed', 'cancelled')
-- ),

-- ranked_orders AS (
--     SELECT
--         order_id,
--         event_id,
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
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at
-- FROM ranked_orders
-- WHERE order_rank = 1
-- ORDER BY order_id;

-- -- Quest 5 — Detecting Invalid Latest Events
-- WITH latest_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) last_order
--     FROM orders_staging_day69
-- ),
-- incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at
--     FROM latest_orders
--     WHERE last_order = 1
--     AND (
--         amount IS NULL
--         OR amount < 0
--         OR (
--             status NOT IN ('pending', 'completed', 'cancelled') 
--             OR status IS NULL
--             )
--         )
-- )

-- SELECT *
-- FROM incorrect_orders;

-- -- Quest 6 — Data Quarantine
-- CREATE TABLE orders_quarantine_day69 (
--     event_id INTEGER PRIMARY KEY,
--     order_id INTEGER NOT NULL,
--     amount NUMERIC(10,2),
--     status VARCHAR(30),
--     updated_at TIMESTAMP,
--     error_reason TEXT NOT NULL
-- );

-- -- Quest 7 — Loading Invalid Events into Quarantine
-- WITH incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day69
--     WHERE amount IS NULL
--     OR amount < 0
--     OR (
--         status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL
--     )
-- )

-- INSERT INTO orders_quarantine_day69 (order_id, event_id, amount, status, updated_at, error_reason)
-- SELECT
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at,
--     'failed_data_quality_checks' 
-- FROM incorrect_orders
-- ON CONFLICT (event_id) DO NOTHING
-- RETURNING order_id, event_id, amount, status, updated_at, error_reason;

-- -- Quest 8 — Error Classification через CASE
-- SELECT
--     event_id,
--     order_id,
--     amount,
--     status,
--     updated_at,
--     CASE
--         WHEN amount IS NULL THEN 'missing_amount'
--         WHEN amount < 0 THEN 'negative_amount'
--         WHEN status IS NULL THEN 'missing_status'
--         WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'invalid_status'
--         ELSE NULL
--     END AS error_reason
-- FROM orders_staging_day69;

-- -- Quest 9 — Data Quarantine с классификацией ошибок
-- WITH incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         CASE
--             WHEN amount IS NULL THEN 'missing_amount'
--             WHEN amount < 0 THEN 'negative_amount'
--             WHEN status IS NULL THEN 'missing_status'
--             WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'invalid_status'
--             ELSE NULL
--         END AS error_reason
--     FROM orders_staging_day69
--     WHERE amount IS NULL
--     OR amount < 0
--     OR (
--         status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL
--     )
-- )

-- INSERT INTO orders_quarantine_day69 (order_id, event_id, amount, status, updated_at, error_reason)
-- SELECT
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at,
--     error_reason
-- FROM incorrect_orders
-- ON CONFLICT (event_id) DO UPDATE
-- SET
--     order_id = EXCLUDED.order_id,
--     amount = EXCLUDED.amount,
--     status = EXCLUDED.status,
--     updated_at = EXCLUDED.updated_at,
--     error_reason = EXCLUDED.error_reason
-- RETURNING order_id, event_id, error_reason;

-- -- Quest 10 — Avoiding Unnecessary Updates
-- WITH incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         CASE
--             WHEN amount IS NULL THEN 'missing_amount'
--             WHEN amount < 0 THEN 'negative_amount'
--             WHEN status IS NULL THEN 'missing_status'
--             WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'invalid_status'
--             ELSE NULL
--         END AS error_reason
--     FROM orders_staging_day69
--     WHERE amount IS NULL
--     OR amount < 0
--     OR (
--         status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL
--     )
-- )

-- INSERT INTO orders_quarantine_day69 (order_id, event_id, amount, status, updated_at, error_reason)
-- SELECT
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at,
--     error_reason
-- FROM incorrect_orders
-- ON CONFLICT (event_id) 
-- DO UPDATE SET
--     error_reason = EXCLUDED.error_reason
-- WHERE orders_quarantine_day69.error_reason IS DISTINCT FROM EXCLUDED.error_reason
-- RETURNING order_id, event_id, error_reason;

-- -- Quest 11 — Loading Valid Orders
-- WITH correct_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day69
--     WHERE amount >= 0
--     AND status IN ('pending', 'completed', 'cancelled')
-- ),

-- ranked_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS order_rank
--     FROM correct_orders
-- )

-- INSERT INTO orders_current_day69 (order_id, event_id, amount, status, updated_at)
-- SELECT 
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at
-- FROM ranked_orders
-- WHERE order_rank = 1
-- ON CONFLICT(order_id)
-- DO UPDATE SET 
--     event_id = EXCLUDED.event_id,
--     amount = EXCLUDED.amount,
--     status = EXCLUDED.status,
--     updated_at = EXCLUDED.updated_at
-- WHERE EXCLUDED.updated_at > orders_current_day69.updated_at
-- OR (
--     EXCLUDED.updated_at = orders_current_day69.updated_at
--     AND EXCLUDED.event_id > orders_current_day69.event_id
--     )
-- RETURNING order_id, event_id, status, updated_at;

-- -- Quest 12 — Atomic Loading
-- BEGIN;
-- -- вставляем значения в карантин:
-- WITH incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         CASE
--             WHEN amount IS NULL THEN 'missing_amount'
--             WHEN amount < 0 THEN 'negative_amount'
--             WHEN status IS NULL THEN 'missing_status'
--             WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'invalid_status'
--             ELSE NULL
--         END AS error_reason
--     FROM orders_staging_day69
--     WHERE amount IS NULL
--     OR amount < 0
--     OR (
--         status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL
--     )
-- )

-- INSERT INTO orders_quarantine_day69 (order_id, event_id, amount, status, updated_at, error_reason)
-- SELECT
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at,
--     error_reason
-- FROM incorrect_orders
-- ON CONFLICT (event_id) 
-- DO UPDATE SET
--     error_reason = EXCLUDED.error_reason
-- WHERE orders_quarantine_day69.error_reason IS DISTINCT FROM EXCLUDED.error_reason
-- RETURNING order_id, event_id, error_reason;

-- -- вставляем корректные значения в целевую таблицу:
-- WITH correct_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at
--     FROM orders_staging_day69
--     WHERE amount >= 0
--     AND status IN ('pending', 'completed', 'cancelled')
-- ),

-- ranked_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         ROW_NUMBER() OVER (
--             PARTITION BY order_id
--             ORDER BY updated_at DESC, event_id DESC
--         ) AS order_rank
--     FROM correct_orders
-- )

-- INSERT INTO orders_current_day69 (order_id, event_id, amount, status, updated_at)
-- SELECT 
--     order_id,
--     event_id,
--     amount,
--     status,
--     updated_at
-- FROM ranked_orders
-- WHERE order_rank = 1
-- ON CONFLICT(order_id)
-- DO UPDATE SET 
--     event_id = EXCLUDED.event_id,
--     amount = EXCLUDED.amount,
--     status = EXCLUDED.status,
--     updated_at = EXCLUDED.updated_at
-- WHERE EXCLUDED.updated_at > orders_current_day69.updated_at
-- OR (
--     EXCLUDED.updated_at = orders_current_day69.updated_at
--     AND EXCLUDED.event_id > orders_current_day69.event_id
--     )
-- RETURNING order_id, event_id, status, updated_at;

-- COMMIT;

-- -- Quest 13 — Pipeline Run Logging
-- INSERT INTO pipeline_runs_day69 (run_id, run_status, records_loaded, created_at)
-- VALUES (1, 'success', 4, DEFAULT)
-- RETURNING run_id, run_status, records_loaded, created_at

-- -- Quest 15 — Failure Logging
-- BEGIN;

-- INSERT INTO pipeline_runs_day69 (run_id, run_status, records_loaded)
-- VALUES (2, 'failed', 0)
-- RETURNING run_id, run_status, records_loaded, created_at;

-- COMMIT;

-- -- Quest 18 — Автоматический подсчёт загруженных строк
-- WITH incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         CASE
--             WHEN amount IS NULL THEN 'missing_amount'
--             WHEN amount < 0 THEN 'negative_amount'
--             WHEN status IS NULL THEN 'missing_status'
--             WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'invalid_status'
--             ELSE NULL
--         END AS error_reason
--     FROM orders_staging_day69
--     WHERE amount IS NULL
--     OR amount < 0
--     OR (
--         status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL
--     )
-- ),
-- quarantine_orders AS (
--     INSERT INTO orders_quarantine_day69 (order_id, event_id, amount, status, updated_at, error_reason)
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         error_reason
--     FROM incorrect_orders
--     ON CONFLICT (event_id) 
--     DO UPDATE SET
--         error_reason = EXCLUDED.error_reason
--     WHERE orders_quarantine_day69.error_reason IS DISTINCT FROM EXCLUDED.error_reason
--     RETURNING event_id
-- )

-- SELECT
--     COUNT(event_id) AS quarantined_count
-- FROM quarantine_orders;

-- -- Quest 19 — Автоматическое журналирование
-- WITH incorrect_orders AS (
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         CASE
--             WHEN amount IS NULL THEN 'missing_amount'
--             WHEN amount < 0 THEN 'negative_amount'
--             WHEN status IS NULL THEN 'missing_status'
--             WHEN status NOT IN ('pending', 'completed', 'cancelled') THEN 'invalid_status'
--             ELSE NULL
--         END AS error_reason
--     FROM orders_staging_day69
--     WHERE amount IS NULL
--     OR amount < 0
--     OR (
--         status NOT IN ('pending', 'completed', 'cancelled') 
--         OR status IS NULL
--     )
-- ),
-- quarantine_orders AS (
--     INSERT INTO orders_quarantine_day69 (order_id, event_id, amount, status, updated_at, error_reason)
--     SELECT
--         order_id,
--         event_id,
--         amount,
--         status,
--         updated_at,
--         error_reason
--     FROM incorrect_orders
--     ON CONFLICT (event_id) 
--     DO UPDATE SET
--         error_reason = EXCLUDED.error_reason
--     WHERE orders_quarantine_day69.error_reason IS DISTINCT FROM EXCLUDED.error_reason
--     RETURNING event_id
-- )

-- INSERT INTO pipeline_runs_day69 (run_id, run_status, records_loaded)
-- SELECT 
--     3,
--     'success',
--     COUNT(*)
-- FROM quarantine_orders
-- RETURNING 
--     run_id, run_status, records_loaded, created_at;

-- Quest 20 — Automatic Load Metrics
WITH correct_orders AS (
    SELECT
        order_id,
        event_id,
        amount,
        status,
        updated_at
    FROM orders_staging_day69
    WHERE amount >= 0
    AND status IN ('pending', 'completed', 'cancelled')
),
ranked_orders AS (
    SELECT
        order_id,
        event_id,
        amount,
        status,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY updated_at DESC, event_id DESC
        ) AS order_rank
    FROM correct_orders
),
loaded_orders AS (
    INSERT INTO orders_current_day69 (order_id, event_id, amount, status, updated_at)
    SELECT 
        order_id,
        event_id,
        amount,
        status,
        updated_at
    FROM ranked_orders
    WHERE order_rank = 1
    ON CONFLICT(order_id)
    DO UPDATE SET 
        event_id = EXCLUDED.event_id,
        amount = EXCLUDED.amount,
        status = EXCLUDED.status,
        updated_at = EXCLUDED.updated_at
    WHERE EXCLUDED.updated_at > orders_current_day69.updated_at
    OR (
        EXCLUDED.updated_at = orders_current_day69.updated_at
        AND EXCLUDED.event_id > orders_current_day69.event_id
        )
    RETURNING order_id
)

INSERT INTO pipeline_runs_day69 (run_id, run_status, records_loaded)
SELECT
    4,
    'success',
    COUNT(order_id) AS loaded_orders
FROM loaded_orders
RETURNING
    run_id, run_status, records_loaded, created_at;