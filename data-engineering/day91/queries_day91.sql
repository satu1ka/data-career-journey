-- Sales Analytics Practice

-- -- Quest 1 — City Revenue Analysis
-- SELECT
--     city,
--     SUM(quantity * unit_price) AS total_revenue,
--     COUNT(DISTINCT order_id) AS total_orders,
--     SUM(quantity) AS total_units,
--     ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
-- FROM sales_day91
-- WHERE status = 'completed'
-- GROUP BY city
-- ORDER BY total_revenue DESC;

-- -- Quest 2 — Daily Sales & Cancellation Analytics
-- SELECT
--     order_date,
--     SUM(quantity * unit_price) FILTER (WHERE status = 'completed') AS completed_revenue,
--     COUNT(DISTINCT order_id) FILTER (WHERE status = 'completed') AS completed_orders,
--     COUNT(DISTINCT order_id) FILTER (WHERE status = 'cancelled') AS cancelled_orders,
--     ROUND((COUNT(DISTINCT order_id) FILTER (WHERE status = 'cancelled') * 1.0
--     /
--     COUNT(DISTINCT order_id) * 100.0), 2) AS cancelled_rate_pct
-- FROM sales_day91
-- GROUP BY order_date
-- ORDER BY order_date

-- -- Quest 3 — Customer Revenue Ranking
-- WITH customer_metrics AS (
--     SELECT
--         customer_id,
--         SUM(quantity * unit_price) AS total_revenue,
--         COUNT(DISTINCT order_id) AS total_orders,
--         ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
--     FROM sales_day91
--     WHERE status = 'completed'
--     GROUP BY customer_id
-- )
-- SELECT
--     customer_id,
--     total_revenue,
--     total_orders,
--     avg_order_value,
--     DENSE_RANK() OVER (
--         ORDER BY total_revenue DESC
--     ) AS revenue_rank
-- FROM customer_metrics
-- WHERE total_orders >= 2
-- ORDER BY revenue_rank, customer_id;

-- -- Quest 4 — Daily Revenue: LAG & Running Total
-- WITH daily_metrics AS (
--     SELECT
--         order_date,
--         SUM(quantity * unit_price) AS total_revenue
--     FROM sales_day91
--     WHERE status = 'completed'
--     GROUP BY order_date
-- )
-- SELECT
--     order_date,
--     total_revenue AS daily_revenue,
--     LAG(total_revenue) OVER (
--         ORDER BY order_date
--     ) AS previous_revenue,
--     total_revenue 
--     -
--     LAG(total_revenue) OVER (
--         ORDER BY order_date
--     ) AS revenue_change,
--     SUM(total_revenue) OVER (
--         ORDER BY order_date
--         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--     ) AS cumulative_revenue
-- FROM daily_metrics
-- ORDER BY order_date;

-- Quest 5 — City & Category Ranking
WITH city_metrics AS (
    SELECT
        city,
        category,
        SUM(quantity * unit_price) AS category_revenue,
        COUNT(DISTINCT order_id) AS total_orders
    FROM sales_day91
    WHERE status = 'completed'
    GROUP BY city, category
    HAVING COUNT(DISTINCT order_id) >= 2
)
SELECT
    city,
    category,
    category_revenue,
    total_orders,
    DENSE_RANK() OVER (
        PARTITION BY city
        ORDER BY category_revenue DESC
    ) AS category_rank
FROM city_metrics
ORDER BY city, category_rank, category;