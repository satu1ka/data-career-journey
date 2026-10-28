-- Day 69 — Atomic Loads & Data Quality
-- PostgreSQL practice setup. Safe to rerun: resets only *_day69 tables.
-- Do not run this script against production data.

DROP TABLE IF EXISTS pipeline_runs_day69;
DROP TABLE IF EXISTS orders_current_day69;
DROP TABLE IF EXISTS orders_staging_day69;

-- Raw incoming events: intentionally permits data quality problems.
CREATE TABLE orders_staging_day69 (
    event_id   INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2),
    status     VARCHAR(20),
    updated_at TIMESTAMP NOT NULL
);

-- Curated table: one current version per order, with business constraints.
CREATE TABLE orders_current_day69 (
    order_id   INTEGER PRIMARY KEY,
    event_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2) NOT NULL,
    status     VARCHAR(20) NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT orders_day69_nonnegative_amount CHECK (amount >= 0),
    CONSTRAINT orders_day69_valid_status CHECK (status IN ('pending', 'completed', 'cancelled'))
);

-- A simple load audit table for upcoming exercises.
CREATE TABLE pipeline_runs_day69 (
    run_id          INTEGER PRIMARY KEY,
    run_status      VARCHAR(10) NOT NULL,
    records_loaded  INTEGER NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pipeline_day69_valid_status CHECK (run_status IN ('success', 'failed')),
    CONSTRAINT pipeline_day69_nonnegative_count CHECK (records_loaded >= 0)
);

INSERT INTO orders_current_day69 (order_id, event_id, amount, status, updated_at)
VALUES
    (201, 10, 150.00, 'completed', '2026-10-26 10:00:00'),
    (202, 20,  40.00, 'pending',   '2026-10-26 11:00:00'),
    (203, 30,  70.00, 'pending',   '2026-10-26 09:00:00');

INSERT INTO orders_staging_day69 (event_id, order_id, amount, status, updated_at)
VALUES
    (11, 201, 150.00, 'pending',   '2026-10-26 09:00:00'), -- stale version
    (12, 201, 150.00, 'completed', '2026-10-26 12:00:00'), -- newer version
    (21, 202,  40.00, 'completed', '2026-10-26 12:30:00'),
    (22, 202,  40.00, 'cancelled', '2026-10-26 13:00:00'), -- latest for 202
    (31, 203,  80.00, 'completed', '2026-10-26 10:00:00'),
    (41, 204,  60.00, 'pending',   '2026-10-26 09:00:00'), -- new order
    (42, 205, -25.00, 'completed', '2026-10-26 11:00:00'), -- invalid: negative amount
    (43, 206,  30.00, 'delivered', '2026-10-26 13:00:00'); -- invalid: status not allowed

-- Start exploring with:
-- SELECT * FROM orders_staging_day69 ORDER BY order_id, event_id;
-- SELECT * FROM orders_current_day69 ORDER BY order_id;