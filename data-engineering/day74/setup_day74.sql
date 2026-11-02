-- Day 74 — Incremental Loading & Watermarks
-- PostgreSQL training dataset. Recreates ONLY tables with suffix _day74.

DROP TABLE IF EXISTS pipeline_state_day74;
DROP TABLE IF EXISTS orders_events_day74;

CREATE TABLE orders_events_day74 (
    event_id     INTEGER PRIMARY KEY,
    order_id     INTEGER NOT NULL,
    amount       NUMERIC(12, 2),
    status       TEXT,
    updated_at   TIMESTAMP NOT NULL,
    ingested_at  TIMESTAMP NOT NULL
);

CREATE TABLE pipeline_state_day74 (
    pipeline_name       TEXT PRIMARY KEY,
    last_ingested_at    TIMESTAMP NOT NULL,
    last_event_id       INTEGER NOT NULL
);

INSERT INTO orders_events_day74 (event_id, order_id, amount, status, updated_at, ingested_at)
VALUES
    (4001, 701, 100.00, 'pending',   '2026-10-30 08:00:00', '2026-10-31 08:00:00'),
    (4002, 702, 200.00, 'pending',   '2026-10-30 09:00:00', '2026-10-31 09:00:00'),
    (4003, 703,  50.00, 'completed', '2026-10-31 10:00:00', '2026-10-31 10:00:00'),
    (4004, 704,  20.00, 'pending',   '2026-10-31 11:00:00', '2026-10-31 11:00:00'),
    (4005, 701, 110.00, 'completed', '2026-10-31 12:00:00', '2026-10-31 12:00:00'),
    (4006, 702, 210.00, 'completed', '2026-10-31 12:10:00', '2026-10-31 12:00:00'),
    (4007, 705, 300.00, 'pending',   '2026-10-31 12:30:00', '2026-10-31 13:00:00'),
    (4008, 703,  55.00, 'cancelled', '2026-10-31 09:00:00', '2026-10-31 13:10:00'),
    (4009, 706, -10.00, 'pending',   '2026-11-01 09:00:00', '2026-11-01 10:00:00'),
    (4010, 707, 120.00, 'unknown',   '2026-11-01 10:00:00', '2026-11-01 11:00:00'),
    (3999, 708,  75.00, 'completed', '2026-10-29 18:00:00', '2026-11-01 11:30:00');

INSERT INTO pipeline_state_day74 (pipeline_name, last_ingested_at, last_event_id)
VALUES ('orders_incremental', '2026-10-31 12:00:00', 4005);

-- Optional inspection queries (run separately if desired):
-- SELECT * FROM pipeline_state_day74;
-- SELECT * FROM orders_events_day74 ORDER BY ingested_at, event_id;
