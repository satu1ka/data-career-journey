-- Day 68 | PostgreSQL
-- Review: deduplication, conditional UPSERT
-- New topic: INSERT / UPDATE / DELETE ... RETURNING
-- Run once to initialize, or rerun to reset all Day 68 practice data.
-- WARNING: rerunning drops the three Day 68 tables and any changes in them.

BEGIN;

DROP TABLE IF EXISTS orders_incoming_day68;
DROP TABLE IF EXISTS orders_current_day68;
DROP TABLE IF EXISTS products_day68;

CREATE TABLE products_day68 (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    quantity     INTEGER NOT NULL DEFAULT 0,
    price        NUMERIC(10, 2) NOT NULL
);

INSERT INTO products_day68 (product_id, product_name, quantity, price)
VALUES
    (101, 'USB cable', 15, 9.90),
    (102, 'Keyboard',   8, 49.90),
    (103, 'Mouse',     20, 24.90),
    (104, 'Monitor',    5, 249.90);

CREATE TABLE orders_current_day68 (
    order_id   INTEGER PRIMARY KEY,
    event_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2) NOT NULL,
    status     VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

INSERT INTO orders_current_day68 (order_id, event_id, amount, status, updated_at)
VALUES
    (201, 10, 250.00, 'completed', '2026-10-25 15:00:00'),
    (202, 20,  90.00, 'pending',   '2026-10-25 12:00:00'),
    (203, 30,  70.00, 'completed', '2026-10-25 17:00:00');

CREATE TABLE orders_incoming_day68 (
    event_id   INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2) NOT NULL,
    status     VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

INSERT INTO orders_incoming_day68 (event_id, order_id, amount, status, updated_at)
VALUES
    (11, 201, 250.00, 'pending',   '2026-10-25 14:00:00'),
    (12, 201, 250.00, 'cancelled', '2026-10-25 16:00:00'),
    (13, 201, 250.00, 'completed', '2026-10-25 16:00:00'),
    (21, 202,  95.00, 'completed', '2026-10-25 13:00:00'),
    (22, 202, 100.00, 'cancelled', '2026-10-25 11:00:00'),
    (31, 203,  70.00, 'completed', '2026-10-25 17:00:00'),
    (40, 204, 149.00, 'pending',   '2026-10-26 09:00:00');

COMMIT;

-- Optional checks (run these separately if you want to inspect the starting data):
-- SELECT * FROM products_day68 ORDER BY product_id;
-- SELECT * FROM orders_current_day68 ORDER BY order_id;
-- SELECT * FROM orders_incoming_day68 ORDER BY order_id, updated_at, event_id;
