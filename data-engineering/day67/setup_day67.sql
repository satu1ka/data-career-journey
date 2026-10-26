-- Day 67 — Data Engineering
-- PostgreSQL setup: deduplication + incremental UPSERT practice
-- IMPORTANT: Re-running this script DROPS and recreates all three training tables.
-- Do not run it against production tables.

BEGIN;

DROP TABLE IF EXISTS orders_incoming;
DROP TABLE IF EXISTS orders_current;
DROP TABLE IF EXISTS orders_raw;

-- Historical versions of orders (for ROW_NUMBER and GROUP BY practice).
CREATE TABLE orders_raw (
    event_id   INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2) NOT NULL,
    status     VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

INSERT INTO orders_raw (event_id, order_id, amount, status, updated_at)
VALUES
    (1, 101, 120.00, 'pending',   '2026-10-20 09:00:00'),
    (2, 101, 120.00, 'completed', '2026-10-20 12:00:00'),
    (3, 102,  60.00, 'completed', '2026-10-20 10:00:00'),
    (4, 102,  60.00, 'cancelled', '2026-10-20 10:00:00'),
    (5, 103,  75.00, 'completed', '2026-10-21 13:00:00'),
    (6, 103,  90.00, 'pending',   '2026-10-21 11:00:00'),
    (7, 104, 200.00, 'completed', '2026-10-22 08:00:00');

-- One current version per order. Unique order_id is required for ON CONFLICT.
CREATE TABLE orders_current (
    order_id   INTEGER PRIMARY KEY,
    event_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2) NOT NULL,
    status     VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

INSERT INTO orders_current (order_id, event_id, amount, status, updated_at)
VALUES
    (201, 10, 250.00, 'completed', '2026-10-25 15:00:00'),
    (202, 15,  90.00, 'pending',   '2026-10-25 13:00:00');

-- Newly arrived events. Order 201 deliberately has multiple versions.
-- Other events let us test stale updates and brand-new orders.
CREATE TABLE orders_incoming (
    event_id   INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2) NOT NULL,
    status     VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

INSERT INTO orders_incoming (event_id, order_id, amount, status, updated_at)
VALUES
    (11, 201, 250.00, 'pending',   '2026-10-25 14:00:00'),
    (12, 201, 250.00, 'cancelled', '2026-10-25 16:00:00'),
    (13, 201, 250.00, 'completed', '2026-10-25 16:00:00'),
    (16, 202,  90.00, 'pending',   '2026-10-25 12:00:00'),
    (20, 204,  65.00, 'pending',   '2026-10-26 08:00:00');

COMMIT;

-- Inspect training data (not a solution to the quest):
SELECT * FROM orders_current ORDER BY order_id;
SELECT * FROM orders_incoming ORDER BY event_id;