-- Day 78 — PostgreSQL EXPLAIN & Query Performance
-- Independent practice dataset. Only practice_orders_day78 is replaced.

DROP TABLE IF EXISTS practice_orders_day78;

CREATE TABLE practice_orders_day78 (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL
);

INSERT INTO practice_orders_day78 (
    order_id,
    customer_id,
    order_date,
    amount,
    status
)
SELECT
    n AS order_id,
    (n % 200) + 1 AS customer_id,
    DATE '2026-01-01' + (n % 300) AS order_date,
    (((n * 37) % 30000) + 100)::NUMERIC / 100 AS amount,
    CASE
        WHEN n % 10 = 0 THEN 'cancelled'
        WHEN n % 7 = 0 THEN 'pending'
        ELSE 'completed'
    END AS status
FROM generate_series(1, 30000) AS g(n);

-- Update statistics so the query planner can estimate row counts.
ANALYZE practice_orders_day78;

-- Verify that the setup loaded correctly.
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM practice_orders_day78;
