-- Day 72 — Weekly Challenge: Order Events Pipeline Audit
-- PostgreSQL. Run in a practice database; it resets only *_day72 tables.

DROP TABLE IF EXISTS pipeline_runs_day72;
DROP TABLE IF EXISTS orders_quarantine_day72;
DROP TABLE IF EXISTS orders_current_day72;
DROP TABLE IF EXISTS orders_staging_day72;

CREATE TABLE orders_staging_day72 (
    event_id   BIGINT PRIMARY KEY,
    order_id   BIGINT NOT NULL,
    amount     NUMERIC(12, 2),
    status     TEXT,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE orders_current_day72 (
    order_id   BIGINT PRIMARY KEY,
    event_id   BIGINT NOT NULL,
    amount     NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    status     TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'cancelled')),
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE orders_quarantine_day72 (
    event_id       BIGINT PRIMARY KEY,
    order_id       BIGINT NOT NULL,
    reason         TEXT NOT NULL,
    quarantined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pipeline_runs_day72 (
    run_id          TEXT PRIMARY KEY,
    total_events    INTEGER NOT NULL,
    invalid_events  INTEGER NOT NULL,
    quality_status  TEXT NOT NULL CHECK (quality_status IN ('PASS', 'FAIL')),
    recorded_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders_staging_day72 (event_id, order_id, amount, status, updated_at) VALUES
    (2001, 701,  80.00, 'pending',   '2026-10-28 09:00:00'),
    (2002, 701,  80.00, 'completed', '2026-10-28 10:00:00'),
    (2003, 702,  45.00, 'completed', '2026-10-28 11:00:00'),
    (2004, 703, 100.00, 'pending',   '2026-10-28 12:00:00'),
    (2005, 704, 120.00, 'completed', '2026-10-28 13:00:00'),
    (2006, 705,  95.00, 'completed', '2026-10-28 15:00:00'),
    (2007, 706,  20.00, 'pending',   '2026-10-28 16:00:00'),
    (2008, 706,  35.00, 'completed', '2026-10-28 16:00:00'),
    (2009, 707, 150.00, 'pending',   '2026-10-28 17:00:00'),
    (2010, 707, -10.00, 'completed', '2026-10-28 18:00:00'),
    (2011, 708,  20.00, 'refunded',  '2026-10-28 18:30:00'),
    (2012, 709,   NULL, 'pending',   '2026-10-28 19:00:00'),
    (2013, 710, 120.00, NULL,       '2026-10-28 19:30:00'),
    (2014, 711,  75.00, 'completed', '2026-10-28 20:00:00'),
    (2015, 712,  30.00, 'completed', '2026-10-28 21:00:00'),
    (2016, 713,  55.00, 'completed', '2026-10-28 22:00:00'),
    (2018, 714,  65.00, 'completed', '2026-10-28 23:00:00'),
    (2019, 715,  23.00, 'completed', '2026-10-29 00:00:00');

INSERT INTO orders_current_day72 (order_id, event_id, amount, status, updated_at) VALUES
    (701, 2001,  80.00, 'pending',   '2026-10-28 09:00:00'),
    (702, 2003,  45.00, 'completed', '2026-10-28 11:00:00'),
    (704, 2999, 120.00, 'completed', '2026-10-28 14:00:00'),
    (705, 2006,  90.00, 'completed', '2026-10-28 15:00:00'),
    (706, 2007,  20.00, 'pending',   '2026-10-28 16:00:00'),
    (707, 2009, 150.00, 'pending',   '2026-10-28 17:00:00'),
    (711, 2014,  75.00, 'completed', '2026-10-28 20:00:00'),
    (712, 2015,  30.00, 'pending',   '2026-10-28 21:00:00'),
    (713, 2998,  55.00, 'completed', '2026-10-28 22:00:00'),
    (714, 1900,  65.00, 'completed', '2026-10-28 23:00:00'),
    (716, 3001,  25.00, 'completed', '2026-10-28 05:00:00');

-- The quarantine and run-log tables are intentionally empty.
-- Verify setup (optional):
-- SELECT COUNT(*) FROM orders_staging_day72;
-- SELECT COUNT(*) FROM orders_current_day72;
