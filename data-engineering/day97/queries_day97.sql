-- -- Quest 1 — Incident Triage: где пропадают заказы?
-- WITH missing_orders AS (
--     SELECT
--         so.order_id,
--         so.customer_id,
--         so.order_date,
--         so.revenue,
--         so.ingested_at
--     FROM source_orders_day95 AS so
--     LEFT JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE fo.order_id IS NULL
-- )
-- SELECT
--     order_id,
--     ingested_at,
--     revenue,
--     CASE
--         WHEN ingested_at <= (
--             SELECT 
--                 last_successful_ingested_at
--             FROM pipeline_state_day95
--             WHERE pipeline_name = 'orders_incremental'
--             )
--         THEN 'MISSED_BEHIND_WATERMARK'
--         WHEN ingested_at > (
--             SELECT 
--                 last_successful_ingested_at
--             FROM pipeline_state_day95
--             WHERE pipeline_name = 'orders_incremental'
--             )    
--         THEN 'PENDING_AFTER_WATERMARK'
--     END AS issue_type
-- FROM missing_orders
-- ORDER BY ingested_at, order_id;

-- -- Quest 2 — Recovery: восстановление пропущенных заказов
-- BEGIN;

-- INSERT INTO fact_orders_day95 (
--     order_id, 
--     customer_id, 
--     order_date, 
--     revenue, 
--     ingested_at
-- )
-- WITH missing_orders AS (
--     SELECT
--         so.order_id,
--         so.customer_id,
--         so.order_date,
--         so.revenue,
--         so.ingested_at
--     FROM source_orders_day95 AS so
--     LEFT JOIN fact_orders_day95 AS fo
--         ON so.order_id = fo.order_id
--     WHERE fo.order_id IS NULL
-- ),
-- orders_with_issue_type AS (
--     SELECT
--         order_id,
--         customer_id,
--         order_date,
--         revenue,
--         ingested_at,
--         CASE
--             WHEN ingested_at <= (
--                 SELECT 
--                     last_successful_ingested_at
--                 FROM pipeline_state_day95
--                 WHERE pipeline_name = 'orders_incremental'
--                 )
--             THEN 'MISSED_BEHIND_WATERMARK'
--             WHEN ingested_at > (
--                 SELECT 
--                     last_successful_ingested_at
--                 FROM pipeline_state_day95
--                 WHERE pipeline_name = 'orders_incremental'
--                 )    
--             THEN 'PENDING_AFTER_WATERMARK'
--         END AS issue_type
--     FROM missing_orders    
-- )
-- SELECT
--     order_id, 
--     customer_id, 
--     order_date, 
--     revenue, 
--     ingested_at
-- FROM orders_with_issue_type AS owit
-- WHERE issue_type = 'MISSED_BEHIND_WATERMARK';

-- COMMIT;

-- -- Проверочные селекты
-- SELECT 
--     COUNT(*) AS total_orders
-- FROM fact_orders_day95;

-- SELECT 
--     *
-- FROM fact_orders_day95
-- WHERE order_id = '1013';

-- SELECT 
--     *
-- FROM fact_orders_day95
-- WHERE order_id = '1014';

-- SELECT 
--     last_successful_ingested_at
-- FROM pipeline_state_day95
-- WHERE pipeline_name = 'orders_incremental';

-- -- Quest 3 — Data Quality Gate: можно ли доверять Fact?
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
-- )
-- SELECT 
--     mo.missing_orders,
--     rm.revenue_mismatches,
--     po.pending_orders,
--     CASE
--         WHEN mo.missing_orders > 0 OR rm.revenue_mismatches > 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_status
-- FROM missing_orders AS mo
-- CROSS JOIN revenue_mismatches AS rm
-- CROSS JOIN pending_orders AS po;

-- -- Quest 4 — Negative Testing: проверяем Data Quality Gate на ошибках
-- BEGIN;

-- UPDATE fact_orders_day95
-- SET revenue = 123132
-- WHERE order_id = '1013';

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
-- )
-- SELECT 
--     mo.missing_orders,
--     rm.revenue_mismatches,
--     po.pending_orders,
--     CASE
--         WHEN mo.missing_orders > 0 OR rm.revenue_mismatches > 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_status
-- FROM missing_orders AS mo
-- CROSS JOIN revenue_mismatches AS rm
-- CROSS JOIN pending_orders AS po;

-- ROLLBACK;

-- -- Quest 5 — Bidirectional Reconciliation
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
-- )
-- SELECT 
--     mo.missing_orders,
--     rm.revenue_mismatches,
--     po.pending_orders,
--     foo.fact_only_orders,
--     CASE
--         WHEN mo.missing_orders > 0 
--             OR rm.revenue_mismatches > 0 
--             OR foo.fact_only_orders > 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS quality_status
-- FROM missing_orders AS mo
-- CROSS JOIN revenue_mismatches AS rm
-- CROSS JOIN pending_orders AS po
-- CROSS JOIN fact_only_orders AS foo;

-- Quest 6 — Negative Testing: Extra Records in Fact
BEGIN;

INSERT INTO fact_orders_day95 (
    order_id,
    customer_id,
    order_date,
    revenue,
    ingested_at
)
VALUES
    (943, 70, DATE '2026-11-23', 75,
        TIMESTAMPTZ '2026-11-23 08:15:00+00');

WITH missing_orders AS (
    SELECT
        COUNT(so.order_id) AS missing_orders
    FROM source_orders_day95 AS so
    LEFT JOIN fact_orders_day95 AS fo
        ON so.order_id = fo.order_id
    WHERE fo.order_id IS NULL
    AND so.ingested_at <= (
        SELECT 
            last_successful_ingested_at
        FROM pipeline_state_day95
        WHERE pipeline_name = 'orders_incremental'
        )
),
revenue_mismatches AS (
    SELECT
        COUNT(fo.order_id) AS revenue_mismatches
    FROM fact_orders_day95 AS fo
    INNER JOIN source_orders_day95 AS so
        ON fo.order_id = so.order_id
    WHERE fo.revenue IS DISTINCT FROM so.revenue
),
pending_orders AS (
    SELECT
        COUNT(so.order_id) AS pending_orders
    FROM source_orders_day95 AS so
    LEFT JOIN fact_orders_day95 AS fo
        ON so.order_id = fo.order_id
    WHERE so.ingested_at > (
            SELECT 
                last_successful_ingested_at
            FROM pipeline_state_day95
            WHERE pipeline_name = 'orders_incremental'
            )
        AND fo.order_id IS NULL
),
fact_only_orders AS (
    SELECT
        COUNT(fo.order_id) AS fact_only_orders
    FROM fact_orders_day95 AS fo
    LEFT JOIN source_orders_day95 AS so
        ON fo.order_id = so.order_id
    WHERE so.order_id IS NULL
)
SELECT 
    mo.missing_orders,
    rm.revenue_mismatches,
    po.pending_orders,
    foo.fact_only_orders,
    CASE
        WHEN mo.missing_orders > 0 
            OR rm.revenue_mismatches > 0 
            OR foo.fact_only_orders > 0 THEN 'FAIL'
        ELSE 'PASS'
    END AS quality_status
FROM missing_orders AS mo
CROSS JOIN revenue_mismatches AS rm
CROSS JOIN pending_orders AS po
CROSS JOIN fact_only_orders AS foo;

ROLLBACK;
