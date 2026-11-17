-- -- Quest 2.1 — убираем лишние пары
-- SELECT
--     *
-- FROM dim_customers_scd_day89_test AS a
-- INNER JOIN dim_customers_scd_day89_test AS b
-- ON a.customer_id = b.customer_id
-- AND a.customer_sk < b.customer_sk;

-- -- Quest 2.2 — Находим пересекающиеся интервалы
-- SELECT
--     *
-- FROM dim_customers_scd_day89_test AS a
-- INNER JOIN dim_customers_scd_day89_test AS b
-- ON a.customer_id = b.customer_id
--     AND a.customer_sk < b.customer_sk
--     AND (a.valid_from < b.valid_to
--         OR b.valid_to IS NULL)
--     AND (b.valid_from < a.valid_to
--         OR a.valid_to IS NULL);

-- -- Quest 3 — Data Quality Report: Overlapping SCD Versions
-- SELECT
--     a.customer_id,
--     a.customer_sk AS version_a,
--     a.city AS city_a,
--     a.valid_from AS valid_from_a,
--     a.valid_to AS valid_to_a,
--     b.customer_sk AS version_b,
--     b.city AS city_b,
--     b.valid_from AS valid_from_b,
--     b.valid_to AS valid_to_b
-- FROM dim_customers_scd_day89_test AS a
-- INNER JOIN dim_customers_scd_day89_test AS b
-- ON a.customer_id = b.customer_id
--     AND a.customer_sk < b.customer_sk
--     AND (a.valid_from < b.valid_to
--         OR b.valid_to IS NULL)
--     AND (b.valid_from < a.valid_to
--         OR a.valid_to IS NULL)
-- ORDER BY a.customer_id, version_a, version_b;

-- -- Quest 4 — Detecting Gaps in SCD History
-- WITH chrono_rows AS (
--     SELECT
--         customer_id,
--         city,
--         valid_from,
--         valid_to,
--         LEAD(valid_from) OVER (
--             PARTITION BY customer_id
--             ORDER BY valid_from
--         ) AS next_valid_from
--     FROM dim_customers_scd_day89_test
-- )
-- SELECT
--     customer_id,
--     city,
--     valid_to,
--     next_valid_from
-- FROM chrono_rows
-- WHERE valid_to < next_valid_from;

-- Quest 5 — SCD Data Quality: объединяем проверки
-- Quest 5.2 — Building a Data Quality Summary
WITH overlaps_pairs AS (
    SELECT
        a.customer_id,
        a.customer_sk AS version_a,
        a.city AS city_a,
        a.valid_from AS valid_from_a,
        a.valid_to AS valid_to_a,
        b.customer_sk AS version_b,
        b.city AS city_b,
        b.valid_from AS valid_from_b,
        b.valid_to AS valid_to_b
    FROM dim_customers_scd_day89_test AS a
    INNER JOIN dim_customers_scd_day89_test AS b
    ON a.customer_id = b.customer_id
        AND a.customer_sk < b.customer_sk
        AND (a.valid_from < b.valid_to
            OR b.valid_to IS NULL)
        AND (b.valid_from < a.valid_to
            OR a.valid_to IS NULL)
    ORDER BY a.customer_id, version_a, version_b
),
chrono_rows AS (
    SELECT
        customer_id,
        city,
        valid_from,
        valid_to,
        LEAD(valid_from) OVER (
            PARTITION BY customer_id
            ORDER BY valid_from
        ) AS next_valid_from
    FROM dim_customers_scd_day89_test
),
gaps AS (
    SELECT
        customer_id,
        city,
        valid_to,
        next_valid_from
    FROM chrono_rows
    WHERE valid_to < next_valid_from
)

SELECT 
    'overlapping_intervals' AS check_name,
    COUNT(*) AS violations_count
FROM overlaps_pairs

UNION ALL

SELECT 
    'gaps_in_history' AS check_name,
    COUNT(*) AS violations_count
FROM gaps;