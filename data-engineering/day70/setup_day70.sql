-- Day 70 — Pipeline Reconciliation & SQL Assertions
-- PostgreSQL setup. Only objects with the _day70 suffix are recreated.
-- Warning: rerunning this script deletes existing Day 70 exercise data.

BEGIN;

DROP TABLE IF EXISTS orders_quarantine_day70;
DROP TABLE IF EXISTS orders_current_day70;
DROP TABLE IF EXISTS orders_staging_day70;

-- Incoming history: keep both valid and invalid events.
CREATE TABLE orders_staging_day70 (
    event_id   INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    amount     NUMERIC(10, 2),
    status     VARCHAR(30),
    updated_at TIMESTAMP NOT NULL
);

-- Materialized latest VALID order state, populated here as a test fixture.
CREATE TABLE orders_current_day70 (
    order_id   INTEGER PRIMARY KEY,
    event_id   INTEGER NOT NULL UNIQUE,
    amount     NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    status     VARCHAR(30) NOT NULL CHECK (status IN ('pending', 'completed', 'cancelled')),
    updated_at TIMESTAMP NOT NULL
);

-- Events excluded because of failing data-quality checks.
CREATE TABLE orders_quarantine_day70 (
    event_id     INTEGER PRIMARY KEY,
    order_id     INTEGER NOT NULL,
    amount       NUMERIC(10, 2),
    status       VARCHAR(30),
    updated_at   TIMESTAMP NOT NULL,
    error_reason TEXT NOT NULL
);

INSERT INTO orders_staging_day70 (event_id, order_id, amount, status, updated_at)
VALUES
    (1001, 501, 100.00, 'pending',   '2026-10-28 09:00:00'),
    (1002, 501, 100.00, 'completed', '2026-10-28 11:00:00'),
    (1003, 502,  50.00, 'pending',   '2026-10-28 10:00:00'),
    (1004, 502,  50.00, 'completed', '2026-10-28 13:00:00'),
    (1005, 503,  90.00, 'completed', '2026-10-28 10:30:00'),
    (1007, 504,  70.00, 'pending',   '2026-10-28 09:00:00'),
    (1006, 504, -20.00, 'completed', '2026-10-28 14:00:00'),
    (1008, 505, 200.00, 'completed', '2026-10-28 10:00:00'),
    (1009, 505, 200.00, 'cancelled', '2026-10-28 10:00:00'),
    (1010, 506,  75.00, 'completed', '2026-10-28 15:00:00'),
    (1011, 507, 110.00, 'unknown',   '2026-10-28 15:30:00');

-- A realistic snapshot that must be audited rather than assumed correct.
INSERT INTO orders_current_day70 (order_id, event_id, amount, status, updated_at)
VALUES
    (501, 1002, 100.00, 'completed', '2026-10-28 11:00:00'),
    (502, 1003,  50.00, 'pending',   '2026-10-28 10:00:00'),
    (504, 1007,  70.00, 'pending',   '2026-10-28 09:00:00'),
    (505, 1008, 200.00, 'completed', '2026-10-28 10:00:00'),
    (506, 1010,  75.00, 'completed', '2026-10-28 15:00:00'),
    (508, 1012,  40.00, 'pending',   '2026-10-28 09:30:00');

INSERT INTO orders_quarantine_day70 (event_id, order_id, amount, status, updated_at, error_reason)
VALUES
    (1006, 504, -20.00, 'completed', '2026-10-28 14:00:00', 'negative_amount');

COMMIT;

-- Optional quick checks (not part of the exercise solution):
-- SELECT COUNT(*) FROM orders_staging_day70;
-- SELECT COUNT(*) FROM orders_current_day70;
-- SELECT COUNT(*) FROM orders_quarantine_day70;
