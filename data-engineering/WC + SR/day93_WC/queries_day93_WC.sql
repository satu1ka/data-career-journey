-- Day 93 — Weekly Challenge: Historical Sales Audit
-- -- Quest 1 — Historical Matching Audit
-- SELECT
--     fo.order_id,
--     fo.customer_id,
--     fo.order_date,
--     COUNT(dc.customer_sk) AS matching_versions
-- FROM fact_orders_day93 AS fo
-- LEFT JOIN dim_customers_day93 AS dc
--     ON fo.customer_id = dc.customer_id
--     AND fo.order_date >= dc.valid_from
--     AND (fo.order_date < dc.valid_to
--     OR dc.valid_to IS NULL)
-- GROUP BY fo.order_id, dc.customer_id
-- HAVING COUNT(dc.customer_sk) <> 1
-- ORDER BY fo.order_id;

-- -- Quest 2 — Historical Revenue Analytics
-- WITH city_metrics AS (
--     SELECT
--         dc.city,
--         SUM(fo.revenue) AS total_revenue,
--         COUNT(fo.order_id) AS total_orders
--     FROM dim_customers_day93 AS dc
--     INNER JOIN fact_orders_day93 AS fo
--         ON fo.customer_id = dc.customer_id
--         AND fo.order_date >= dc.valid_from
--         AND (fo.order_date < dc.valid_to
--         OR dc.valid_to IS NULL)
--     WHERE fo.status = 'completed'
--     GROUP BY dc.city
-- )
-- SELECT
--     city,
--     total_revenue,
--     total_orders,
--     ROUND(total_revenue / total_orders, 2) AS avg_order_value,
--     DENSE_RANK() OVER (
--         ORDER BY total_revenue DESC
--     ) AS revenue_rank
-- FROM city_metrics
-- ORDER BY revenue_rank, city;

-- Quest 3 — Data Quality Investigation
WITH order_matches AS (
    SELECT
        fo.order_id,
        fo.customer_id,
        fo.order_date,
        COUNT(dc.customer_sk) AS matching_versions
    FROM fact_orders_day93 AS fo
    LEFT JOIN dim_customers_day93 AS dc
        ON fo.customer_id = dc.customer_id
        AND fo.order_date >= dc.valid_from
        AND (fo.order_date < dc.valid_to
        OR dc.valid_to IS NULL)
    GROUP BY fo.order_id
)
SELECT 
    om.order_id,
    om.customer_id,
    om.matching_versions,
    CASE
        WHEN om.matching_versions > 1 THEN 'MULTIPLE_MATCHES'
        WHEN om.matching_versions = 0
            AND NOT EXISTS (
                SELECT 1
                FROM dim_customers_day93 AS dc
                WHERE dc.customer_id = om.customer_id
            ) THEN 'CUSTOMER_NOT_FOUND'
        WHEN om.matching_versions = 0 THEN 'NO_VALID_VERSION'
    END AS issue_type
FROM order_matches AS om
WHERE om.matching_versions <> 1
ORDER BY order_id;