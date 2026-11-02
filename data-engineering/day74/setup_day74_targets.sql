-- Day 74 — Additional target tables for incremental loading practice
-- Run AFTER setup_day74.sql.
-- WARNING: Re-running this script resets ONLY orders_current_day74
-- and orders_quarantine_day74. It does not modify events or pipeline_state.

DROP TABLE IF EXISTS orders_quarantine_day74;
DROP TABLE IF EXISTS orders_current_day74;

CREATE TABLE orders_current_day74 (
    order_id    INTEGER PRIMARY KEY,
    event_id    INTEGER NOT NULL,
    amount      NUMERIC(12, 2) NOT NULL,
    status      TEXT NOT NULL,
    updated_at  TIMESTAMP NOT NULL
);

CREATE TABLE orders_quarantine_day74 (
    event_id       INTEGER PRIMARY KEY,
    order_id       INTEGER NOT NULL,
    amount         NUMERIC(12, 2),
    status         TEXT,
    updated_at     TIMESTAMP NOT NULL,
    ingested_at    TIMESTAMP NOT NULL,
    reason         TEXT NOT NULL,
    quarantined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- State before the batch beginning immediately after watermark (2026-10-31 12:00, 4005).
INSERT INTO orders_current_day74 (order_id, event_id, amount, status, updated_at)
VALUES
    (701, 4005, 110.00, 'completed', '2026-10-31 12:00:00'),
    (702, 4002, 200.00, 'pending',   '2026-10-30 09:00:00'),
    (703, 4003,  50.00, 'completed', '2026-10-31 10:00:00'),
    (704, 4004,  20.00, 'pending',   '2026-10-31 11:00:00');

-- Quarantine is initially empty.
