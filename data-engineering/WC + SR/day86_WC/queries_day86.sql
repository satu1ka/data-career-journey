-- -- Quest 1 — Independent Source Validation
-- SELECT
--     so.order_date AS report_date,
--     sc.city,
--     SUM(soi.quantity * soi.unit_price_at_order) AS source_revenue,
--     COUNT(DISTINCT soi.order_id) AS source_orders,
--     COUNT(soi.quantity) AS source_items
-- FROM src_order_items_day84 AS soi
-- INNER JOIN src_orders_day84 AS so
-- ON soi.order_id = so.order_id
-- INNER JOIN src_customers_day84 AS sc
-- ON so.customer_id = sc.customer_id
-- WHERE so.order_status = 'completed'
-- GROUP BY so.order_date, sc.city;

-- -- Quest 2 — Independent Warehouse Validation
-- SELECT
--     fs.order_date AS report_date,
--     dc.city,
--     SUM(fs.line_amount) AS warehouse_revenue,
--     COUNT(DISTINCT fs.order_id) AS warehouse_orders,
--     COUNT(*) AS warehouse_items
-- FROM fact_sales_day84 AS fs
-- INNER JOIN dim_customers_day84 AS dc
-- ON fs.customer_id = dc.customer_id
-- WHERE fs.order_status = 'completed'
-- GROUP BY fs.order_date, dc.city;

-- Quest 3 — Building the Reconciliation Report
WITH source_metrics AS (
    SELECT
        so.order_date AS report_date,
        sc.city,
        SUM(soi.quantity * soi.unit_price_at_order) AS source_revenue,
        COUNT(DISTINCT soi.order_id) AS source_orders,
        COUNT(soi.quantity) AS source_items
    FROM src_order_items_day84 AS soi
    INNER JOIN src_orders_day84 AS so
    ON soi.order_id = so.order_id
    INNER JOIN src_customers_day84 AS sc
    ON so.customer_id = sc.customer_id
    WHERE so.order_status = 'completed'
    GROUP BY so.order_date, sc.city
),
warehouse_metrics AS (
    SELECT
        fs.order_date AS report_date,
        dc.city,
        SUM(fs.line_amount) AS warehouse_revenue,
        COUNT(DISTINCT fs.order_id) AS warehouse_orders,
        COUNT(*) AS warehouse_items
    FROM fact_sales_day84 AS fs
    INNER JOIN dim_customers_day84 AS dc
    ON fs.customer_id = dc.customer_id
    WHERE fs.order_status = 'completed'
    GROUP BY fs.order_date, dc.city
)

SELECT 
    COALESCE(sm.report_date, wm.report_date) AS report_date,
    COALESCE(sm.city, wm.city) AS report_city,
    sm.source_revenue,
    wm.warehouse_revenue,
    sm.source_orders,
    wm.warehouse_orders,
    sm.source_items,
    wm.warehouse_items,
    COALESCE(sm.source_revenue, 0) - COALESCE(wm.warehouse_revenue, 0) AS revenue_diff
FROM source_metrics AS sm
FULL OUTER JOIN warehouse_metrics AS wm
ON (sm.report_date = wm.report_date 
    AND sm.city = wm.city)
WHERE sm.source_revenue IS DISTINCT FROM wm.warehouse_revenue
    OR sm.source_orders IS DISTINCT FROM wm.warehouse_orders
    OR sm.source_items IS DISTINCT FROM wm.warehouse_items;