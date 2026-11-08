-- Day 79 — Weekly Challenge: Parcel Tracking Incident
-- PostgreSQL 14+; standalone training dataset.
-- IMPORTANT: recreates ONLY the five *_day79 tables below.
-- Run ONCE before starting the challenge. Re-running resets your progress.

BEGIN;

DROP TABLE IF EXISTS parcel_processed_day79;
DROP TABLE IF EXISTS parcel_quarantine_day79;
DROP TABLE IF EXISTS parcel_current_day79;
DROP TABLE IF EXISTS parcel_events_day79;
DROP TABLE IF EXISTS pipeline_state_day79;

-- Raw carrier events. Deliberately allows invalid status/weight and out-of-order events.
CREATE TABLE parcel_events_day79 (
    event_id      INTEGER PRIMARY KEY,
    parcel_id     INTEGER NOT NULL,
    status        TEXT,
    weight_kg     NUMERIC(8, 2),
    occurred_at   TIMESTAMP NOT NULL,  -- business version timestamp
    ingested_at   TIMESTAMP NOT NULL   -- ingestion cursor timestamp
);

-- Current/latest valid business version per parcel.
CREATE TABLE parcel_current_day79 (
    parcel_id    INTEGER PRIMARY KEY,
    event_id     INTEGER NOT NULL,
    status       TEXT NOT NULL,
    weight_kg    NUMERIC(8, 2) NOT NULL,
    occurred_at  TIMESTAMP NOT NULL
);

-- Invalid events are retained here, independently of current state.
CREATE TABLE parcel_quarantine_day79 (
    event_id       INTEGER PRIMARY KEY,
    parcel_id      INTEGER NOT NULL,
    status         TEXT,
    weight_kg      NUMERIC(8, 2),
    occurred_at    TIMESTAMP NOT NULL,
    ingested_at    TIMESTAMP NOT NULL,
    reason         TEXT NOT NULL,
    quarantined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- A processing receipt for EVERY event handled: accepted or rejected.
-- An accepted event can still be older than current and thus not replace it.
CREATE TABLE parcel_processed_day79 (
    event_id       INTEGER PRIMARY KEY,
    parcel_id      INTEGER NOT NULL,
    outcome        TEXT NOT NULL CHECK (outcome IN ('ACCEPTED', 'REJECTED')),
    ingested_at    TIMESTAMP NOT NULL,
    processed_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pipeline_state_day79 (
    pipeline_name    TEXT PRIMARY KEY,
    last_ingested_at TIMESTAMP NOT NULL,
    last_event_id    INTEGER NOT NULL
);

INSERT INTO pipeline_state_day79 (pipeline_name, last_ingested_at, last_event_id)
VALUES ('parcel_tracking', '2026-11-06 10:00:00', 5105);

INSERT INTO parcel_events_day79
    (event_id, parcel_id, status, weight_kg, occurred_at, ingested_at)
VALUES
    (5101, 801, 'registered', 2.50, '2026-11-06 09:00:00', '2026-11-06 09:10:00'),
    (5102, 802, 'in_transit', 1.20, '2026-11-06 09:15:00', '2026-11-06 09:20:00'),
    (5103, 803, 'registered', 3.00, '2026-11-06 09:25:00', '2026-11-06 09:35:00'),
    (5104, 804, 'unknown', 4.00, '2026-11-06 09:40:00', '2026-11-06 09:45:00'),
    (5105, 804, 'in_transit', 4.00, '2026-11-06 09:55:00', '2026-11-06 10:00:00'),
    -- New events at and after the previous watermark.
    (5106, 801, 'delivered', 2.50, '2026-11-06 10:05:00', '2026-11-06 10:00:00'),
    (5107, 802, 'registered', 1.20, '2026-11-06 09:00:00', '2026-11-06 10:15:00'),
    (5108, 803, 'in_transit', 3.00, '2026-11-06 10:10:00', '2026-11-06 10:20:00'),
    (5109, 804, 'delivered', 4.00, '2026-11-06 09:55:00', '2026-11-06 10:30:00'),
    (5110, 805, 'delivered', 6.00, '2026-11-06 10:35:00', '2026-11-06 10:40:00'),
    (5111, 806, 'delivered', -1.00, '2026-11-06 10:45:00', '2026-11-06 10:50:00'),
    (5112, 807, 'lost', 2.20, '2026-11-06 10:50:00', '2026-11-06 11:00:00'),
    (5113, 810, 'delivered', NULL, '2026-11-06 11:05:00', '2026-11-06 11:10:00'),
    -- These two events were committed late, after a prior processing run.
    -- Their timestamps are intentionally behind the recorded watermark.
    (5098, 808, 'registered', 1.00, '2026-11-06 09:15:00', '2026-11-06 09:30:00'),
    (5097, 809, 'delivered', 1.50, '2026-11-06 07:15:00', '2026-11-06 07:40:00');

INSERT INTO parcel_current_day79
    (parcel_id, event_id, status, weight_kg, occurred_at)
VALUES
    (801, 5101, 'registered', 2.50, '2026-11-06 09:00:00'),
    (802, 5102, 'in_transit', 1.20, '2026-11-06 09:15:00'),
    (803, 5103, 'registered', 3.00, '2026-11-06 09:25:00'),
    (804, 5105, 'in_transit', 4.00, '2026-11-06 09:55:00');

INSERT INTO parcel_quarantine_day79
    (event_id, parcel_id, status, weight_kg, occurred_at, ingested_at, reason)
VALUES
    (5104, 804, 'unknown', 4.00,
     '2026-11-06 09:40:00', '2026-11-06 09:45:00', 'INVALID_STATUS');

INSERT INTO parcel_processed_day79
    (event_id, parcel_id, outcome, ingested_at)
VALUES
    (5101, 801, 'ACCEPTED', '2026-11-06 09:10:00'),
    (5102, 802, 'ACCEPTED', '2026-11-06 09:20:00'),
    (5103, 803, 'ACCEPTED', '2026-11-06 09:35:00'),
    (5104, 804, 'REJECTED', '2026-11-06 09:45:00'),
    (5105, 804, 'ACCEPTED', '2026-11-06 10:00:00');

ANALYZE parcel_events_day79;
ANALYZE parcel_current_day79;
ANALYZE parcel_processed_day79;

COMMIT;

-- Read-only sanity checks (not solutions to the challenges):
SELECT 'parcel_events_day79' AS table_name, COUNT(*) AS rows_count FROM parcel_events_day79
UNION ALL
SELECT 'parcel_current_day79', COUNT(*) FROM parcel_current_day79
UNION ALL
SELECT 'parcel_quarantine_day79', COUNT(*) FROM parcel_quarantine_day79
UNION ALL
SELECT 'parcel_processed_day79', COUNT(*) FROM parcel_processed_day79
UNION ALL
SELECT 'pipeline_state_day79', COUNT(*) FROM pipeline_state_day79
ORDER BY table_name;
