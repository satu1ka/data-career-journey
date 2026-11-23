-- -- Day 95 — Incremental Loading: Watermarks & Batch Processing
-- -- Quest 1.1 — Incremental Extraction
-- SELECT
--     order_id,
--     order_date,
--     ingested_at,
--     revenue
-- FROM source_orders_day95
-- WHERE ingested_at > (
--     SELECT last_successful_ingested_at
--     FROM pipeline_state_day95
--     WHERE pipeline_name = 'orders_incremental'
-- )
--     AND ingested_at <= TIMESTAMPTZ '2026-11-21 09:00:00+00'
-- ORDER BY ingested_at, order_id;

-- Quest 1.4 — Atomic Incremental Loading
BEGIN;
-- Quest 1.2 — Incremental INSERT with Deduplication
INSERT INTO fact_orders_day95 (
    order_id,
    customer_id,
    order_date,
    revenue,
    ingested_at
)
SELECT
    so.order_id,
    so.customer_id,
    so.order_date,
    so.revenue,
    so.ingested_at
FROM source_orders_day95 AS so
WHERE so.ingested_at > (
    SELECT last_successful_ingested_at
    FROM pipeline_state_day95
    WHERE pipeline_name = 'orders_incremental'
)
    AND so.ingested_at <= TIMESTAMPTZ '2026-11-21 09:00:00+00'
    AND NOT EXISTS (
        SELECT 1 
        FROM fact_orders_day95 AS fo
        WHERE fo.order_id = so.order_id
    );

-- Quest 1.3 — Updating the Watermark
UPDATE pipeline_state_day95
SET last_successful_ingested_at = TIMESTAMPTZ '2026-11-21 09:00:00+00'
WHERE pipeline_name = 'orders_incremental';

SELECT  
    COUNT(*) AS orders_count_in_fact
FROM fact_orders_day95;

SELECT 
    last_successful_ingested_at AS new_watermark
FROM pipeline_state_day95
WHERE pipeline_name = 'orders_incremental';

COMMIT;