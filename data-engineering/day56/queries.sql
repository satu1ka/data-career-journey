-- -- Quest 1 — разогрев: frame + ranking
-- WITH orders_with_rolling_avg AS (
--     SELECT 
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--         ) AS rolling_avg
--     FROM orders_day54
-- ),
-- orders_with_ranks AS (
--     SELECT 
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         rolling_avg,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY rolling_avg DESC, created_at, order_id
--         ) AS row_rank
--     FROM orders_with_rolling_avg
-- )

-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     rolling_avg
-- FROM orders_with_ranks
-- WHERE row_rank = 1;

-- -- Quest 2 — frame + filter + ranking
-- WITH orders_with_previous_2_avg AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--         ) AS previous_2_avg
--     FROM orders_day54
-- ),
-- orders_with_ranks AS (
--     SELECT 
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         previous_2_avg,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at, order_id
--         ) AS row_rank
--     FROM orders_with_previous_2_avg
--     WHERE amount > previous_2_avg
-- )

-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     previous_2_avg
-- FROM orders_with_ranks
-- WHERE row_rank = 1;

-- -- Quest 4 — несколько FILTER в одном GROUP BY
-- SELECT
--     customer_id,
--     COUNT(*) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     COUNT(*) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_orders,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_revenue,
--     SUM(amount) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_revenue
-- FROM orders_day56
-- GROUP BY customer_id;

-- -- Quest 5 — FILTER vs WHERE
-- SELECT
--     customer_id,
--     COUNT(order_id) AS total_orders, 
--     COUNT(*) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     COUNT(*) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_orders,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_revenue,
--     SUM(amount) AS total_revenue
-- FROM orders_day56
-- GROUP BY customer_id;

-- -- Quest 7 — FILTER + COALESCE
-- SELECT
--     customer_id,
--     COUNT(order_id) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     COUNT(order_id) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_orders,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_revenue,
--     COALESCE(
--         SUM(amount) FILTER (
--             WHERE status = 'pending'
--         ),
--         0 
--     ) AS pending_revenue
-- FROM orders_day56
-- GROUP BY customer_id;

-- -- Quest 8 — доля completed revenue
-- WITH orders_with_metrics AS (
--     SELECT
--         customer_id,
--         SUM(amount) AS total_revenue,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         ) AS completed_revenue
--     FROM orders_day56
--     GROUP BY customer_id
-- )
-- SELECT
--     *,
--     completed_revenue / total_revenue AS completed_shares
-- FROM orders_with_metrics

-- -- Quest 9 — теперь строго одним SELECT
-- SELECT
--     customer_id,
--     COUNT(order_id) AS total_orders,
--     COUNT(order_id) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     COUNT(order_id) FILTER (
--         WHERE status = 'completed'
--     )::NUMERIC
--     /
--     COUNT(order_id) AS completed_share_by_count
-- FROM orders_day56
-- GROUP BY customer_id;

-- В PostgreSQL:
-- COUNT(...)
-- возвращает целочисленный тип (BIGINT).
-- Поэтому, чтобы не получать 0, нужно приводить к NUMERIC

-- -- Quest 10 — FILTER + несколько типов агрегатов
-- SELECT
--     customer_id,
--     COUNT(order_id) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_orders,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_revenue,
--     AVG(amount) FILTER (
--         WHERE status = 'completed'
--     ) AS completed_avg_amount,
--     COUNT(order_id) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_orders,
--     AVG(amount) FILTER (
--         WHERE status = 'pending'
--     ) AS pending_avg_amount
-- FROM orders_day56
-- GROUP BY customer_id;

-- -- Quest 11 — FILTER + HAVING
-- WITH customer_revenue AS (
--     SELECT 
--         customer_id,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         ) AS completed_revenue,
--         COALESCE(
--             SUM(amount) FILTER (
--                 WHERE status = 'pending'
--             ), 
--             0
--         ) AS pending_revenue
--     FROM orders_day56
--     GROUP BY customer_id
-- )

-- SELECT 
--     customer_id,
--     completed_revenue,
--     pending_revenue
-- FROM customer_revenue
-- WHERE completed_revenue > pending_revenue;

-- -- Quest 12 — FILTER + share
-- WITH customer_metrics AS (
--     SELECT
--         customer_id,
--         SUM(amount) AS total_revenue,
--         SUM(amount) FILTER (
--             WHERE status = 'completed'
--         ) AS completed_revenue,
--         COALESCE(
--             SUM(amount) FILTER (
--                 WHERE status = 'pending'
--             ),
--             0
--         ) AS pending_revenue
--     FROM orders_day56
--     GROUP BY customer_id
-- )

-- SELECT
--     customer_id,
--     total_revenue,
--     completed_revenue,
--     pending_revenue,
--     completed_revenue / total_revenue AS completed_share,
--     pending_revenue / total_revenue AS pending_share
-- FROM customer_metrics;

-- -- Quest 13 — FILTER внутри Window Function
-- SELECT
--     order_id,
--     customer_id,
--     status,
--     amount,
--     SUM(amount) FILTER (
--         WHERE status = 'completed'
--     ) OVER (
--         PARTITION BY customer_id
--     ) AS customer_completed_revenue,
--     COALESCE(
--         SUM(amount) FILTER (
--             WHERE status = 'pending'
--         ) OVER (
--             PARTITION BY customer_id
--         ),
--         0
--     ) AS customer_pending_revenue
-- FROM orders_day56;

-- Quest 14 — FILTER + window + доля
SELECT
    order_id,
    customer_id,
    status,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
    ) AS customer_total_revenue,
    SUM(amount) FILTER (
        WHERE status = 'completed'
    ) OVER (
        PARTITION BY customer_id
    ) AS customer_completed_revenue,
    SUM(amount) FILTER (
        WHERE status = 'completed'
    ) OVER (
        PARTITION BY customer_id
    )
    /
    SUM(amount) OVER (
        PARTITION BY customer_id
    ) AS completed_share_of_customer
FROM orders_day56;