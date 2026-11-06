-- Day 78 — PostgreSQL EXPLAIN: как база выполняет SQL
-- Quest 1 — Первый Query Execution Plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    amount
FROM practice_orders_day78
WHERE customer_id = 2
ORDER BY amount DESC;

-- Quest 3 — Создаём первый индекс
CREATE INDEX idx_orders_day78_customer
ON practice_orders_day78 (customer_id);

-- Quest 4 — Когда PostgreSQL откажется от индекса?
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    amount
FROM practice_orders_day78
WHERE customer_id BETWEEN 1 AND 180
ORDER BY amount DESC;

-- Quest 5 — А что изменится с LIMIT?
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    amount
FROM practice_orders_day78
WHERE customer_id BETWEEN 1 AND 180
ORDER BY amount DESC
LIMIT 10;

-- Quest 6 — Composite Index
CREATE INDEX idx_orders_day78_customer_amount
ON practice_orders_day78 (customer_id, amount DESC);

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    amount
FROM practice_orders_day78
WHERE customer_id = 2
ORDER BY amount DESC
LIMIT 10;

-- Quest 7 — Что будет, если убрать LIMIT?
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    amount
FROM practice_orders_day78
WHERE customer_id = 2
ORDER BY amount DESC;

-- Quest 8 — А что, если запретить Bitmap Scan?
BEGIN;

SET LOCAL enable_bitmapscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    amount
FROM practice_orders_day78
WHERE customer_id = 2
ORDER BY amount DESC;

ROLLBACK;