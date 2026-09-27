-- -- Review 4 — маленький SQL
-- SELECT
--     store,
--     COUNT(*) as orders_count,
--     SUM(price * quantity) as total_revenue
-- FROM orders_day36
-- WHERE status = 'completed'
-- GROUP BY store
-- ORDER BY total_revenue DESC;

-- Review 5 — CASE + aggregation
SELECT
    store,
    COUNT(*) as orders_count,
    SUM(
        CASE
            WHEN shipped_at IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS shipped_orders
FROM orders_day36
GROUP BY store;