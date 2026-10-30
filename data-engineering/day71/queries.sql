-- -- Day 71 — SQL Testing & Data Quality Assertions
-- WITH test_cases AS (
--     SELECT *
--     FROM (VALUES
--         (1, 100, 0, 100, 0, 'PASS'),
--         (2, 100, 5, 100, 0, 'PASS'),
--         (3, 100, 6, 100, 0, 'FAIL'),
--         (4, 20, 5, 20, 0, 'FAIL'),
--         (5, 100, 0, 100, 2, 'FAIL'),
--         (6, 0, 0, 0, 0, 'FAIL'),
--         (7, 100, 0, 0, 0, 'FAIL'),
--         (8, 99, 5, 100, 0, 'FAIL')
--     ) AS t(
--         test_id,
--         total_events,
--         invalid_events,
--         total_orders,
--         failed_orders,
--         expected_status
--     )
-- ),
-- actual_result AS (
--     SELECT
--         test_id,
--         total_events,
--         invalid_events,
--         total_orders,
--         failed_orders,
--         expected_status,
--         CASE
--             WHEN failed_orders > 0 
--                 OR total_orders = 0 
--                 OR total_events = 0
--                 OR (invalid_events * 100.0
--                 / 
--                 NULLIF(total_events, 0)) > 5
--             THEN 'FAIL'
--             ELSE 'PASS'
--         END AS actual_status
--     FROM test_cases
-- )

-- SELECT  
--     test_id,
--     expected_status,
--     actual_status,
--     CASE
--         WHEN expected_status IS DISTINCT FROM actual_status THEN 'ERROR'
--         ELSE 'OK'
--     END AS test_result
-- FROM actual_result
-- ORDER BY test_id;

-- -- Quest 5: Test Suite Summary
-- WITH test_cases AS (
--     SELECT *
--     FROM (VALUES
--         (1, 100, 0, 100, 0, 'PASS'),
--         (2, 100, 5, 100, 0, 'PASS'),
--         (3, 100, 6, 100, 0, 'FAIL'),
--         (4, 20, 5, 20, 0, 'FAIL'),
--         (5, 100, 0, 100, 2, 'FAIL'),
--         (6, 0, 0, 0, 0, 'FAIL'),
--         (7, 100, 0, 0, 0, 'FAIL'),
--         (8, 99, 5, 100, 0, 'FAIL')
--     ) AS t(
--         test_id,
--         total_events,
--         invalid_events,
--         total_orders,
--         failed_orders,
--         expected_status
--     )
-- ),
-- actual_result AS (
--     SELECT
--         test_id,
--         total_events,
--         invalid_events,
--         total_orders,
--         failed_orders,
--         expected_status,
--         CASE
--             WHEN failed_orders > 0 
--                 OR total_orders = 0 
--                 OR total_events = 0
--                 OR (invalid_events * 100.0
--                 / 
--                 NULLIF(total_events, 0)) > 5
--             THEN 'FAIL'
--             ELSE 'PASS'
--         END AS actual_status
--     FROM test_cases
-- ),
-- result_metrics AS (
--     SELECT
--         COUNT(test_id) AS total_tests,
--         COUNT(test_id) FILTER (
--             WHERE expected_status IS NOT DISTINCT FROM actual_status
--         ) AS passed_tests,
--         COUNT(test_id) FILTER (
--             WHERE expected_status IS DISTINCT FROM actual_status
--         ) AS failed_tests
--     FROM actual_result
-- )

-- SELECT 
--     total_tests,
--     passed_tests,
--     failed_tests,
--     CASE
--         WHEN failed_tests > 0 
--             OR total_tests = 0 THEN 'FAIL'
--         ELSE 'PASS'
--     END AS suite_status
-- FROM result_metrics;

-- Quest 6: Failed Tests Diagnostics
WITH test_cases AS (
    SELECT *
    FROM (VALUES
        (1, 100, 0, 100, 0, 'PASS'),
        (2, 100, 5, 100, 0, 'PASS'),
        (3, 100, 6, 100, 0, 'FAIL'),
        (4, 20, 5, 20, 0, 'FAIL'),
        (5, 100, 0, 100, 2, 'FAIL'),
        (6, 0, 0, 0, 0, 'FAIL'),
        (7, 100, 0, 0, 0, 'FAIL'),
        (8, 99, 5, 100, 0, 'FAIL')
    ) AS t(
        test_id,
        total_events,
        invalid_events,
        total_orders,
        failed_orders,
        expected_status
    )
),
actual_result AS (
    SELECT
        test_id,
        total_events,
        invalid_events,
        total_orders,
        failed_orders,
        expected_status,
        CASE
            WHEN failed_orders > 0 
                OR total_orders = 0 
                OR total_events = 0
                OR (invalid_events * 100
                / 
                NULLIF(total_events, 0)) > 5
            THEN 'FAIL'
            ELSE 'PASS'
        END AS actual_status
    FROM test_cases
)

SELECT
    test_id,
    total_events,
    invalid_events,
    expected_status,
    actual_status
FROM actual_result
WHERE actual_status IS DISTINCT FROM expected_status
ORDER BY test_id;